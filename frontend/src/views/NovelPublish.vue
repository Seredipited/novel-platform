<template>
  <div class="page-container publish-page">
    <div class="clay-card publish-card">
      <h1 class="page-title">✍️ 发布小说</h1>
      <el-form :model="form" label-position="top" class="publish-form">
        <el-form-item label="书名">
          <el-input v-model="form.title" placeholder="输入小说名称" class="clay-el-input" />
        </el-form-item>
        <el-form-item label="作者">
          <el-input v-model="form.author" placeholder="输入作者名" class="clay-el-input" />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="form.categoryId" placeholder="选择分类" class="clay-el-select">
            <el-option v-for="cat in categories" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="封面">
          <el-upload class="cover-upload" action="#" :auto-upload="false" :show-file-list="false" @change="handleCover">
            <div class="cover-uploader">
              <span v-if="!form.coverImg" class="upload-icon">📷</span>
              <img v-else :src="form.coverImg" class="cover-preview" />
            </div>
          </el-upload>
        </el-form-item>
        <el-form-item label="标签">
          <el-input v-model="form.tags" placeholder="用逗号分隔多个标签" class="clay-el-input" />
        </el-form-item>
        <el-form-item label="简介">
          <el-input v-model="form.description" type="textarea" :rows="5" placeholder="写下小说的简介..." class="clay-el-textarea" />
        </el-form-item>
        <el-form-item>
          <button class="clay-btn clay-btn-primary publish-btn" @click="handlePublish" :disabled="publishing">
            {{ publishing ? '发布中...' : '📤 发布小说' }}
          </button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import { getCategories, publishNovel } from "../api/novel";
import { ElMessage } from "element-plus";

const router = useRouter();
const categories = ref([]);
const publishing = ref(false);
const form = reactive({
  title: "", author: "", categoryId: null, description: "", coverImg: "", tags: ""
});

const fetchCategories = async () => {
  const res = await getCategories();
  categories.value = res.data || [];
};

const handleCover = (file) => {
  form.coverImg = URL.createObjectURL(file.raw);
};

const handlePublish = async () => {
  if (!form.title || !form.author) {
    ElMessage.warning("请填写书名和作者");
    return;
  }
  publishing.value = true;
  try {
    const res = await publishNovel(form);
    ElMessage.success("发布成功！");
    router.push("/novel/" + res.data);
  } finally { publishing.value = false; }
};

onMounted(fetchCategories);
</script>

<style lang="scss" scoped>
.publish-card { max-width: 700px; margin: 0 auto; padding: 40px; }
.publish-form :deep(.el-form-item__label) { font-weight: 600; color: var(--clay-text); padding-bottom: 8px; }
.clay-el-input :deep(.el-input__wrapper) { border-radius: 16px; box-shadow: var(--clay-inset); border: none; background: var(--clay-bg); }
.clay-el-select :deep(.el-input__wrapper) { border-radius: 16px; box-shadow: var(--clay-inset); border: none; background: var(--clay-bg); }
.clay-el-textarea :deep(.el-textarea__inner) { border-radius: 16px; box-shadow: var(--clay-inset); border: none; background: var(--clay-bg); }
.cover-uploader { width: 140px; height: 200px; border: 2px dashed #d9d0c8; border-radius: 16px; display: flex; align-items: center; justify-content: center; cursor: pointer; background: var(--clay-bg); transition: border-color 0.2s; }
.cover-uploader:hover { border-color: var(--clay-primary); }
.upload-icon { font-size: 40px; }
.cover-preview { width: 100%; height: 100%; object-fit: cover; border-radius: 14px; }
.publish-btn { margin-top: 8px; }
</style>
