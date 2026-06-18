<template>
  <div class="page-container chapter-read" v-loading="loading">
    <div class="read-nav">
      <router-link :to="'/novel/' + novelId" class="clay-btn">⬅ 返回详情</router-link>
      <span class="read-title">{{ chapter?.title || '加载中...' }}</span>
      <div class="read-nav-btns">
        <button class="clay-btn" :disabled="!prevChapter" @click="goChapter(prevChapter)">上一章</button>
        <button class="clay-btn" :disabled="!nextChapter" @click="goChapter(nextChapter)">下一章</button>
      </div>
    </div>

    <div class="read-content clay-card" v-if="chapter">
      <h1 class="chapter-title">{{ chapter.title }}</h1>
      <div class="chapter-body" v-html="formattedContent"></div>
    </div>

    <div class="read-footer">
      <button class="clay-btn" :disabled="!prevChapter" @click="goChapter(prevChapter)">⬅ 上一章</button>
      <button v-if="isAuthor && isLastChapter" class="clay-btn clay-btn-ai" @click="openAiContinue">🧠 AI 续写</button>
      <button class="clay-btn clay-btn-primary" :disabled="!nextChapter" @click="goChapter(nextChapter)">下一章 ➡</button>
    </div>

    <!-- AI 续写弹窗 -->
    <el-dialog v-model="aiDialog.visible" title="🧠 AI 智能续写" width="800px" top="5vh" destroy-on-close>
      <!-- generating 步骤 -->
      <template v-if="aiDialog.step === 'generating'">
        <div v-loading="aiDialog.loading" style="min-height:300px">
          <p v-if="!aiDialog.result" style="color:#999;text-align:center;padding-top:80px">
            AI 正在根据当前章节内容创作续写...
          </p>
          <div v-else class="ai-continue-result">
            <h3>✨ AI 续写内容</h3>
            <div class="ai-continue-text">{{ aiDialog.result }}</div>
          </div>
        </div>
      </template>

      <!-- publish 步骤 -->
      <template v-if="aiDialog.step === 'publish'">
        <div class="ai-publish-form">
          <el-input v-model="aiDialog.title" placeholder="章节标题" size="large" style="margin-bottom:16px" />
          <el-input v-model="aiDialog.result" type="textarea" :rows="15" placeholder="章节正文..." />
        </div>
      </template>

      <template #footer>
        <template v-if="aiDialog.step === 'generating'">
          <el-button @click="aiDialog.visible = false">关闭</el-button>
          <el-button v-if="!aiDialog.result" type="primary" @click="doAiContinue" :loading="aiDialog.loading">开始续写</el-button>
          <template v-else>
            <el-button @click="aiDialog.step = 'publish'">发布为章节</el-button>
            <el-button type="primary" @click="doAiContinue" :loading="aiDialog.loading">重新生成</el-button>
          </template>
        </template>
        <template v-if="aiDialog.step === 'publish'">
          <el-button @click="aiDialog.step = 'generating'">⬅ 返回</el-button>
          <el-button type="primary" @click="publishAiChapter" :loading="aiDialog.loading">📤 发布章节</el-button>
        </template>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { getChapterDetail, getChapterList, addChapter } from "../api/chapter";
import { aiContinue } from "../api/ai";
import { getNovelDetail } from "../api/novel";
import { useUserStore } from "../store";
import { ElMessage } from "element-plus";

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();
const novelId = computed(() => route.params.id);
const chapter = ref(null);
const chapters = ref([]);
const loading = ref(false);
const novel = ref(null);

const isAuthor = computed(() => {
  if (!userStore.user || !novel.value) return false;
  return userStore.user.id === novel.value.authorId;
});

const isLastChapter = computed(() => {
  if (!chapters.value.length) return false;
  const idx = chapters.value.findIndex(c => c.id == route.params.chapterId);
  return idx === chapters.value.length - 1;
});

const currentIndex = computed(() => chapters.value.findIndex(c => c.id == route.params.chapterId));
const prevChapter = computed(() => currentIndex.value > 0 ? chapters.value[currentIndex.value - 1] : null);
const nextChapter = computed(() => currentIndex.value < chapters.value.length - 1 ? chapters.value[currentIndex.value + 1] : null);

const formattedContent = computed(() => {
  if (!chapter.value?.content) return "";
  return chapter.value.content.split("\n").map(p => p.trim()).filter(p => p).map(p => `<p>${p}</p>`).join("");
});

const aiDialog = reactive({
  visible: false, loading: false, step: "generating",
  title: "", result: ""
});

const fetchData = async () => {
  loading.value = true;
  try {
    const novelRes = await getNovelDetail(novelId.value);
    novel.value = novelRes.data;
    const chRes = await getChapterList(novelId.value);
    chapters.value = chRes.data || [];
    const detailRes = await getChapterDetail(route.params.chapterId);
    chapter.value = detailRes.data;
  } finally { loading.value = false; }
};

const goChapter = (ch) => {
  if (ch) router.push(`/novel/${novelId.value}/chapter/${ch.id}`);
};

const openAiContinue = () => {
  aiDialog.visible = true;
  aiDialog.step = "generating";
  aiDialog.result = "";
  aiDialog.title = chapter.value ? "续：" + chapter.value.title : "";
  doAiContinue();
};

const doAiContinue = async () => {
  aiDialog.loading = true;
  try {
    const ctx = chapter.value?.content ? chapter.value.content.substring(Math.max(0, chapter.value.content.length - 1500)) : "";
    const res = await aiContinue({ context: ctx });
    aiDialog.result = res.data?.content || "";
  } catch (e) {
    ElMessage.error(e.message || "AI 续写失败");
  } finally { aiDialog.loading = false; }
};

const publishAiChapter = async () => {
  if (!aiDialog.title.trim() || !aiDialog.result.trim()) {
    ElMessage.warning("请填写章节标题和正文");
    return;
  }
  aiDialog.loading = true;
  try {
    await addChapter({ novelId: novelId.value, title: aiDialog.title, content: aiDialog.result });
    ElMessage.success("章节发布成功");
    aiDialog.visible = false;
    await fetchData();
  } catch (e) {
    ElMessage.error(e.message || "发布失败");
  } finally { aiDialog.loading = false; }
};

watch(() => route.params.chapterId, fetchData);
onMounted(async () => {
  await userStore.fetchProfile();
  fetchData();
});
</script>

<style lang="scss" scoped>
.read-nav { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; gap: 16px; flex-wrap: wrap; }
.read-title { font-size: 18px; font-weight: 600; }
.read-nav-btns { display: flex; gap: 12px; }
.read-content { padding: 48px 64px; max-width: 800px; margin: 0 auto; }
.chapter-title { text-align: center; font-size: 28px; font-weight: 800; margin-bottom: 32px; padding-bottom: 20px; border-bottom: 2px solid var(--clay-bg); }
.chapter-body { font-size: 18px; line-height: 2; }
.chapter-body :deep(p) { text-indent: 2em; margin-bottom: 1em; }
.read-footer { display: flex; justify-content: center; gap: 20px; margin-top: 24px; padding: 20px 0; }
.clay-btn-ai { background: linear-gradient(135deg, #e8d5f5, #d5e8f5); border: 1px solid #c8b8d8; color: #5a4888; font-weight: 600; }
.clay-btn-ai:hover { background: linear-gradient(135deg, #dcc8f0, #c8ddf0); }

.ai-continue-result { margin-top: 16px; }
.ai-continue-result h3 { font-size: 18px; font-weight: 700; margin-bottom: 16px; color: #333; }
.ai-continue-text { font-size: 16px; line-height: 2.2; color: #555; white-space: pre-wrap; background: #faf8f5; border-radius: 12px; padding: 24px; max-height: 400px; overflow-y: auto; }

.ai-publish-form { display: flex; flex-direction: column; }
</style>
