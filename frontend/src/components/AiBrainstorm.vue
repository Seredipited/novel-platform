<template>
  <el-dialog v-model="visible" title="🧠 AI 小说构思助手" width="900px" top="3vh" destroy-on-close>
    <!-- Step 1: 输入 -->
    <div v-if="step === 'input'" class="ai-input-step">
      <p class="ai-hint">输入题材和核心冲突，AI 将为你生成完整的人物卡和世界观设定</p>
      <div class="ai-form">
        <el-select v-model="genre" placeholder="选择题材" size="large" style="width:100%;margin-bottom:16px">
          <el-option label="古言 / 古装言情" value="古言" />
          <el-option label="现言 / 现代言情" value="现言" />
          <el-option label="玄幻 / 东方玄幻" value="玄幻" />
          <el-option label="仙侠 / 修仙" value="仙侠" />
          <el-option label="无限流 / 快穿" value="无限流" />
          <el-option label="悬疑 / 推理" value="悬疑" />
          <el-option label="科幻 / 末世" value="科幻" />
          <el-option label="都市 / 职场" value="都市" />
          <el-option label="轻小说 / 二次元" value="轻小说" />
          <el-option label="耽美 / 纯爱" value="耽美" />
        </el-select>
        <el-input v-model="conflict" type="textarea" :rows="4" 
          placeholder="核心冲突，例如：女主重生回十年前，带着记忆报复渣男、逆袭翻身..."
          size="large" />
        <div style="margin-top:16px;display:flex;gap:12px;align-items:center">
          <el-button type="primary" size="large" @click="doBrainstorm" :loading="loading" :disabled="!genre || !conflict">
            ✨ 开始生成构思
          </el-button>
          <span v-if="brainstormHistory.length > 0" class="ai-history-badge">
            📋 已有 {{ brainstormHistory.length }} 次构思记录
          </span>
        </div>
      </div>
    </div>

    <!-- Step 2: 结果展示（构思 markdown） -->
    <div v-else-if="step === 'result'" class="ai-result-step">
      <div class="ai-result-actions">
        <el-button @click="step = 'input'">⬅ 返回修改</el-button>
        <el-button type="warning" @click="doGenerateChapters" :loading="loading">✍️ 生成正文章节</el-button>
        <el-button type="primary" @click="$emit('apply', result)">✅ 填入发布框</el-button>
      </div>

      <!-- 历史构思记录 -->
      <div v-if="brainstormHistory.length > 1" class="ai-history-bar">
        <el-collapse>
          <el-collapse-item :title="'📋 历史构思记录（共 ' + brainstormHistory.length + ' 次）'">
            <div v-for="(h, i) in brainstormHistory.slice(0, -1)" :key="i" class="ai-history-item">
              <el-tag size="small" type="info" style="margin-bottom:8px">第{{ i + 1 }}次 · {{ h.genre }}</el-tag>
              <div class="ai-history-text">{{ h.conflict.substring(0, 100) }}{{ h.conflict.length > 100 ? '...' : '' }}</div>
            </div>
          </el-collapse-item>
        </el-collapse>
      </div>

      <div class="ai-result-body" v-loading="loading">
        <template v-if="result && result.parsed">
          <div v-if="result.parsed.worldSetting" class="ai-section">
            <h3>🌍 世界观设定</h3>
            <div class="ai-content" v-html="renderMd(result.parsed.worldSetting)"></div>
          </div>
          <div v-if="result.parsed.mainCharacter" class="ai-section">
            <h3>👤 主角人物卡</h3>
            <div class="ai-content" v-html="renderMd(result.parsed.mainCharacter)"></div>
          </div>
          <div v-if="result.parsed.supportingCast" class="ai-section">
            <h3>👥 关键配角</h3>
            <div class="ai-content" v-html="renderMd(result.parsed.supportingCast)"></div>
          </div>
          <div v-if="result.parsed.storyOutline" class="ai-section">
            <h3>📖 故事主线</h3>
            <div class="ai-content" v-html="renderMd(result.parsed.storyOutline)"></div>
          </div>
          <div v-if="result.raw && !result.parsed.worldSetting" class="ai-section">
            <h3>📝 AI 生成结果</h3>
            <div class="ai-content" style="white-space:pre-wrap">{{ result.raw }}</div>
          </div>
        </template>
      </div>
    </div>

    <!-- Step 3: 生成多章节 -->
    <div v-else-if="step === 'writing'" class="ai-writing-step" v-loading="writing.loading">
      <template v-if="!writing.generated">
        <div class="ai-writing-placeholder">
          <p>🤖 AI 正在根据构思内容创作多个连贯章节...</p>
          <p class="ai-writing-hint">正在生成 3 章正文 + 发布 4 项设定集，请耐心等待 60-120 秒</p>
        </div>
      </template>
      <template v-else>
        <div class="ai-writing-preview">
          <div class="ai-writing-actions">
            <el-button @click="step = 'result'">⬅ 返回构思</el-button>
            <el-button type="success" size="large" @click="handlePublishAllChapters" :loading="writing.publishing">
              📤 一键发布全部（4项设定集 + {{ writing.chapters.length }}章正文）
            </el-button>
          </div>
          <div v-if="writing.settingsPublished" class="ai-settings-published">
            ✅ 设定集已发布（世界观、主角人物卡、关键配角、故事主线）
          </div>
          <div class="ai-chapters-preview">
            <div v-for="(ch, i) in writing.chapters" :key="i" class="ai-chapter-card">
              <div class="ai-chapter-card-header">
                <span class="ai-chapter-num">📖 第{{ i + 1 }}章</span>
                <span class="ai-chapter-card-title">{{ ch.title }}</span>
              </div>
              <div class="ai-chapter-card-body">
                <p class="ai-chapter-card-content">{{ ch.content.substring(0, 200) }}{{ ch.content.length > 200 ? '...' : '' }}</p>
                <el-collapse>
                  <el-collapse-item title="查看完整正文">
                    <div class="ai-chapter-content-full">{{ ch.content }}</div>
                  </el-collapse-item>
                </el-collapse>
              </div>
            </div>
          </div>
        </div>
      </template>
    </div>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, computed } from "vue";
import { aiBrainstorm, aiGenerateChapters } from "../api/ai";
import { ElMessage } from "element-plus";

const props = defineProps({ modelValue: Boolean });
const emit = defineEmits(["update:modelValue", "apply", "publishAllChapters"]);

// ========== 构思历史记录 ==========
const brainstormHistory = ref([]); // [{ genre, conflict, raw, parsed }]

// ========== 状态 ==========
const step = ref("input");
const genre = ref("古言");
const conflict = ref("");
const loading = ref(false);
const result = ref(null);

const writing = reactive({
  loading: false,
  publishing: false,
  generated: false,
  settingsPublished: false,
  chapters: []
});

const visible = computed({
  get: () => props.modelValue,
  set: (val) => emit("update:modelValue", val)
});

// ========== 生成构思 ==========
const doBrainstorm = async () => {
  loading.value = true;
  try {
    const res = await aiBrainstorm({ genre: genre.value, conflict: conflict.value });
    result.value = res.data;

    // 记录到历史
    brainstormHistory.value.push({
      genre: genre.value,
      conflict: conflict.value,
      raw: res.data.raw,
      parsed: res.data.parsed
    });

    step.value = "result";
    ElMessage.success("构思已生成，已记录到历史中");
  } catch (e) {
    ElMessage.error(e.message || "AI 调用失败");
  } finally {
    loading.value = false;
  }
};

// ========== 生成多章节 ==========
const doGenerateChapters = async () => {
  if (!result.value?.raw) {
    ElMessage.warning("请先生成构思内容");
    return;
  }

  step.value = "writing";
  writing.generated = false;
  writing.settingsPublished = false;
  writing.chapters = [];
  writing.loading = true;

  // 构建历史上下文
  let historyContext = "";
  if (brainstormHistory.value.length > 1) {
    const history = brainstormHistory.value.slice(0, -1);
    historyContext = history.map((h, i) =>
      `[第${i + 1}次构思 · 题材：${h.genre}]\n冲突：${h.conflict}\n输出：${h.raw}`
    ).join("\n\n---\n\n");
  }

  try {
    // 1. 先发布 4 项设定集
    writing.settingsPublished = true;

    // 2. 调用 AI 生成多个章节（附带历史上下文）
    const res = await aiGenerateChapters({
      brainstormRaw: result.value.raw,
      historyContext: historyContext,
      chapterCount: 3
    });
    writing.chapters = res.data.chapters || [];
    writing.generated = true;

    ElMessage.success(`已生成 ${writing.chapters.length} 个连贯章节，可以一键发布全部`);
  } catch (e) {
    ElMessage.error(e.message || "生成章节失败");
    step.value = "result";
  } finally {
    writing.loading = false;
  }
};

// ========== 一键发布全部（设定集 + 正文章节） ==========
const handlePublishAllChapters = () => {
  if (!result.value?.parsed) {
    ElMessage.warning("没有构思内容");
    return;
  }
  if (writing.chapters.length === 0) {
    ElMessage.warning("还没有生成章节");
    return;
  }
  emit("publishAllChapters", {
    settings: result.value.parsed,
    chapters: writing.chapters
  });
};

const renderMd = (text) => {
  if (!text) return "";
  return text
    .replace(/\n/g, "<br>")
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/^- (.+)/gm, "&nbsp;&nbsp;• $1");
};
</script>

<style lang="scss" scoped>
.ai-hint { color: #999; margin-bottom: 16px; font-size: 14px; }
.ai-form { margin-top: 8px; }
.ai-history-badge { font-size: 13px; color: #888; background: #f5f5f5; padding: 4px 12px; border-radius: 12px; }
.ai-history-bar { margin-bottom: 16px; }
.ai-history-item { padding: 8px 16px; border-left: 3px solid #e0d5c7; margin-bottom: 8px; background: #faf8f5; border-radius: 4px; }
.ai-history-text { font-size: 13px; color: #888; line-height: 1.6; }
.ai-result-actions { display: flex; gap: 12px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #eee; }
.ai-result-body { max-height: 50vh; overflow-y: auto; }
.ai-section { margin-bottom: 24px; }
.ai-section h3 { font-size: 18px; font-weight: 700; margin-bottom: 12px; color: #333; }
.ai-content { font-size: 15px; line-height: 2; color: #555; }

/* Step 3: 生成多个章节 */
.ai-writing-step { min-height: 300px; }
.ai-writing-placeholder { text-align: center; padding-top: 80px; color: #999; font-size: 16px; }
.ai-writing-hint { font-size: 13px; color: #bbb; margin-top: 8px; }
.ai-writing-preview { }
.ai-writing-actions { display: flex; gap: 12px; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px solid #eee; justify-content: space-between; align-items: center; }
.ai-settings-published { background: #f0f9eb; border: 1px solid #b3e19d; border-radius: 8px; padding: 8px 16px; margin-bottom: 16px; font-size: 14px; color: #67c23a; }
.ai-chapters-preview { max-height: 60vh; overflow-y: auto; }
.ai-chapter-card { background: #faf8f5; border: 1px solid #e0d5c7; border-radius: 12px; padding: 16px; margin-bottom: 12px; transition: border-color 0.2s; }
.ai-chapter-card:hover { border-color: #c9b8a8; }
.ai-chapter-card-header { display: flex; align-items: baseline; gap: 8px; margin-bottom: 8px; }
.ai-chapter-num { font-size: 14px; color: var(--clay-primary, #c9a96e); font-weight: 700; white-space: nowrap; }
.ai-chapter-card-title { font-size: 18px; font-weight: 700; color: #333; }
.ai-chapter-card-body { }
.ai-chapter-card-content { font-size: 14px; line-height: 1.8; color: #777; text-indent: 2em; }
.ai-chapter-content-full { font-size: 16px; line-height: 2.2; color: #444; white-space: pre-wrap; text-indent: 2em; padding: 12px 0; max-height: 300px; overflow-y: auto; }
</style>
