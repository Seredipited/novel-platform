<template>
  <div class="page-container novel-detail" v-loading="loading">
    <template v-if="novel">
      <div class="detail-header clay-card">
        <div class="detail-cover">
          <img v-if="novel.coverImg" :src="novel.coverImg" :alt="novel.title" class="cover-img" />
          <span v-else class="cover-icon">📖</span>
        </div>
        <div class="detail-meta">
          <h1 class="detail-title">{{ novel.title }}</h1>
          <p class="detail-author">✍️ {{ novel.author }}</p>
          <div class="detail-tags">
            <span class="tag">⭐ {{ novel.score || '0.0' }}</span>
            <span class="tag">👁️ {{ novel.clickCount || 0 }} 阅读</span>
            <span class="tag">❤️ {{ novel.favoriteCount || 0 }} 收藏</span>
            <span class="tag">📝 {{ novel.wordCount || 0 }} 字</span>
            <span class="tag status-tag" :class="novel.status">{{ novel.status === 'ongoing' ? '连载中' : '已完结' }}</span>
          </div>
          <p class="detail-desc">{{ novel.description }}</p>
        </div>
      </div>

      <div class="detail-actions">
        <button class="clay-btn clay-btn-primary" @click="startReading">📖 开始阅读</button>
        <button v-if="isAuthor" class="clay-btn" @click="showBrainstorm = true">🧠 AI 构思</button>
      </div>

      <!-- 作者专属：发布新章节 -->
      <div v-if="isAuthor" class="publish-chapter clay-card">
        <h2 class="section-title">✍️ 发布新章节</h2>
        <div class="publish-form">
          <input v-model="newChapter.title" class="clay-input" placeholder="章节标题，如「第12章 风云突变」" />
          <textarea v-model="newChapter.content" class="clay-textarea" placeholder="章节正文..." rows="8"></textarea>
          <div class="publish-btns">
            <button class="clay-btn clay-btn-primary" @click="handlePublishChapter" :disabled="publishing">
              {{ publishing ? '发布中...' : '📤 发布章节' }}
            </button>
          </div>
        </div>
      </div>

      <div class="chapter-list clay-card">
        <div class="chapter-header">
          <h2 class="section-title">📑 章节列表</h2>
          <span class="chapter-count">共 {{ chapters.length }} 章</span>
        </div>
        <div v-if="chapters.length === 0" class="empty-chapters">暂无章节，快来写第一章吧</div>
        <div v-else class="chapters">
          <div v-for="ch in chapters" :key="ch.id" class="chapter-item">
            <router-link :to="'/novel/' + novel.id + '/chapter/' + ch.id" class="chapter-link">
              <span class="chapter-num">第{{ ch.chapterNumber }}章</span>
              <span class="chapter-title">{{ ch.title }}</span>
            </router-link>
            <span class="chapter-word-count">{{ ch.wordCount || 0 }}字</span>
            <span class="chapter-time">{{ formatTime(ch.createTime) }}</span>
            <button v-if="isAuthor" class="clay-btn-small" @click="openEditChapter(ch)">✏️ 编辑</button>
            <button v-if="isAuthor" class="clay-btn-small clay-btn-danger" @click="handleDeleteChapter(ch)">🗑 删除</button>
          </div>
        </div>
      </div>

      <!-- 编辑章节弹窗 -->
      <el-dialog v-model="editDialog.visible" title="编辑章节" width="700px" destroy-on-close>
        <div class="edit-form">
          <el-input v-model="editDialog.title" placeholder="章节标题" size="large" style="margin-bottom:16px" />
          <el-input v-model="editDialog.content" type="textarea" :rows="15" placeholder="章节正文..." />
        </div>
        <template #footer>
          <el-button @click="editDialog.visible = false">取消</el-button>
          <el-button type="primary" @click="handleUpdateChapter" :loading="editDialog.loading">保存修改</el-button>
        </template>
      </el-dialog>
    </template>

    <!-- AI 构思弹窗 -->
    <AiBrainstorm v-model="showBrainstorm" @apply="onApplyBrainstorm" @publishAllChapters="onPublishAllChapters" />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { getNovelDetail } from "../api/novel";
import { getChapterList, addChapter, updateChapter, deleteChapter } from "../api/chapter";
import { useUserStore } from "../store";
import { ElMessage, ElMessageBox } from "element-plus";
import AiBrainstorm from "../components/AiBrainstorm.vue";

const route = useRoute();
const router = useRouter();
const userStore = useUserStore();

const novel = ref(null);
const chapters = ref([]);
const loading = ref(false);
const publishing = ref(false);
const showBrainstorm = ref(false);

const isAuthor = computed(() => {
  if (!userStore.user || !novel.value) return false;
  return userStore.user.id === novel.value.authorId;
});

const newChapter = reactive({ title: "", content: "" });
const editDialog = reactive({
  visible: false, loading: false,
  id: null, title: "", content: ""
});

const fetchData = async () => {
  loading.value = true;
  try {
    const novelRes = await getNovelDetail(route.params.id);
    novel.value = novelRes.data;
    const chRes = await getChapterList(route.params.id);
    chapters.value = chRes.data || [];
  } finally { loading.value = false; }
};

const startReading = () => {
  if (chapters.value.length > 0) {
    router.push('/novel/' + novel.value.id + '/chapter/' + chapters.value[0].id);
  }
};

const handlePublishChapter = async () => {
  if (!newChapter.title.trim() || !newChapter.content.trim()) {
    ElMessage.warning("请填写章节标题和正文");
    return;
  }
  publishing.value = true;
  try {
    await addChapter({ novelId: novel.value.id, title: newChapter.title, content: newChapter.content });
    ElMessage.success("发布成功");
    newChapter.title = "";
    newChapter.content = "";
    await fetchData();
  } catch (e) {
    ElMessage.error(e.message || "发布失败");
  } finally { publishing.value = false; }
};

const openEditChapter = (ch) => {
  editDialog.id = ch.id;
  editDialog.title = ch.title;
  editDialog.content = ch.content || "";
  editDialog.visible = true;
};

const handleUpdateChapter = async () => {
  if (!editDialog.title.trim() || !editDialog.content.trim()) {
    ElMessage.warning("请填写完整");
    return;
  }
  editDialog.loading = true;
  try {
    await updateChapter({
      id: editDialog.id,
      novelId: novel.value.id,
      title: editDialog.title,
      content: editDialog.content,
      chapterNumber: chapters.value.find(c => c.id === editDialog.id)?.chapterNumber
    });
    ElMessage.success("修改成功");
    editDialog.visible = false;
    await fetchData();
  } catch (e) {
    ElMessage.error(e.message || "修改失败");
  } finally { editDialog.loading = false; }
};

const onApplyBrainstorm = (result) => {
  showBrainstorm.value = false;
  if (result?.raw) {
    newChapter.content = result.raw;
    ElMessage.success("AI 构思已填入发布框，可以修改后发布");
  }
};

// 一键发布：设定集（4项） + AI 生成的正文章节（多章）
const CH_SECTION_MAP = [
  { key: "worldSetting",  title: "📖 设定集 · 世界观" },
  { key: "mainCharacter", title: "👤 设定集 · 主角人物卡" },
  { key: "supportingCast", title: "👥 设定集 · 关键配角" },
  { key: "storyOutline",  title: "📝 设定集 · 故事主线" },
];

const onPublishAllChapters = async ({ settings, chapters }) => {
  showBrainstorm.value = false;
  if (!settings || !chapters || chapters.length === 0) {
    ElMessage.warning("没有可发布的内容");
    return;
  }
  publishing.value = true;
  let settingsOk = 0;
  let chaptersOk = 0;
  try {
    // 1. 发布 4 项设定集
    const settingSections = CH_SECTION_MAP.filter(s => settings[s.key]);
    for (const s of settingSections) {
      await addChapter({
        novelId: novel.value.id,
        title: s.title,
        content: settings[s.key]
      });
      settingsOk++;
    }

    // 2. 发布生成的正文章节
    for (const ch of chapters) {
      await addChapter({
        novelId: novel.value.id,
        title: ch.title,
        content: ch.content
      });
      chaptersOk++;
    }

    ElMessage.success(`已发布 ${settingsOk} 项设定集 + ${chaptersOk} 章正文`);
    await fetchData();
  } catch (e) {
    ElMessage.error(`已发布 ${settingsOk} 设定 + ${chaptersOk} 章节时出错: ${e.message || "发布失败"}`);
  } finally {
    publishing.value = false;
  }
};

// 删除章节
const handleDeleteChapter = async (ch) => {
  try {
    await ElMessageBox.confirm(`确定删除章节「${ch.title}」吗？此操作不可撤销。`, "删除确认", {
      confirmButtonText: "确认删除",
      cancelButtonText: "取消",
      type: "warning",
      confirmButtonClass: "el-button--danger"
    });
  } catch {
    return; // 用户取消
  }
  try {
    await deleteChapter(ch.id);
    ElMessage.success("已删除");
    await fetchData();
  } catch (e) {
    ElMessage.error(e.message || "删除失败");
  }
};

const formatTime = (t) => {
  if (!t) return "";
  return new Date(t).toLocaleDateString("zh-CN");
};

onMounted(async () => {
  await userStore.fetchProfile();
  fetchData();
});
</script>

<style lang="scss" scoped>
.detail-header { display: flex; gap: 32px; padding: 32px; align-items: flex-start; }
.detail-cover { width: 160px; height: 220px; border-radius: 16px; background: linear-gradient(135deg, #a8d8ea, #f9a8a8); display: flex; align-items: center; justify-content: center; flex-shrink: 0; overflow: hidden; }
.cover-img { width: 100%; height: 100%; object-fit: cover; }
.cover-icon { font-size: 60px; }
.detail-meta { flex: 1; }
.detail-title { font-size: 32px; font-weight: 800; margin-bottom: 8px; }
.detail-author { font-size: 16px; color: var(--clay-text-light); margin-bottom: 16px; }
.detail-tags { display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 20px; }
.tag { padding: 4px 14px; border-radius: 20px; background: var(--clay-bg); font-size: 13px; }
.status-tag.ongoing { background: #fde8d0; color: #e8915a; }
.status-tag.completed { background: #d0f0e0; color: #78b8a0; }
.detail-desc { font-size: 15px; line-height: 1.8; color: #6a5a4a; }
.detail-actions { display: flex; gap: 16px; margin: 24px 0; }

.publish-chapter { padding: 24px; margin-bottom: 24px; }
.section-title { font-size: 20px; font-weight: 700; margin-bottom: 16px; }
.publish-form { display: flex; flex-direction: column; gap: 12px; }
.clay-input { padding: 12px 16px; border: 1px solid #e0d5c7; border-radius: 12px; font-size: 15px; outline: none; background: #fefefe; }
.clay-input:focus { border-color: #c9b8a8; }
.clay-textarea { padding: 12px 16px; border: 1px solid #e0d5c7; border-radius: 12px; font-size: 15px; outline: none; background: #fefefe; resize: vertical; line-height: 1.8; font-family: inherit; }
.clay-textarea:focus { border-color: #c9b8a8; }
.publish-btns { display: flex; gap: 12px; }

.chapter-list { padding: 24px; }
.chapter-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.chapter-count { font-size: 14px; color: var(--clay-text-light); }
.chapters { display: flex; flex-direction: column; }
.chapter-item { display: flex; align-items: center; gap: 12px; padding: 10px 16px; border-radius: 10px; transition: background 0.2s; }
.chapter-item:hover { background: var(--clay-bg); }
.chapter-link { display: flex; gap: 16px; text-decoration: none; color: var(--clay-text); flex: 1; min-width: 0; }
.chapter-num { color: var(--clay-primary); font-weight: 600; min-width: 70px; flex-shrink: 0; }
.chapter-title { color: var(--clay-text); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.chapter-word-count { font-size: 13px; color: #aaa; flex-shrink: 0; }
.chapter-time { font-size: 13px; color: #bbb; flex-shrink: 0; }
.clay-btn-small { padding: 4px 12px; border: 1px solid #e0d5c7; border-radius: 8px; background: #faf8f5; font-size: 13px; cursor: pointer; color: #888; transition: all 0.2s; }
.clay-btn-small:hover { border-color: #c9b8a8; color: #555; }
.clay-btn-danger { color: #e67575; }
.clay-btn-danger:hover { border-color: #e67575; background: #fff0f0; color: #d44; }
.empty-chapters { text-align: center; padding: 40px; color: var(--clay-text-light); }

.edit-form { display: flex; flex-direction: column; gap: 12px; }
</style>
