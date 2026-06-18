<template>
  <div class="page-container user-center" v-loading="loading">
    <div class="profile-section clay-card">
      <div class="profile-header">
        <div class="profile-avatar">
          <span class="avatar-icon">👤</span>
        </div>
        <div class="profile-info">
          <h2>{{ userStore.user?.nickname || userStore.user?.username }}</h2>
          <p>用户名：{{ userStore.user?.username }}</p>
          <p>邮箱：{{ userStore.user?.email || '未设置' }}</p>
          <p>个人简介：{{ userStore.user?.bio || '这个用户很懒，什么都没写...' }}</p>
          <p class="join-date">加入时间：{{ userStore.user?.createTime }}</p>
        </div>
        <button class="clay-btn" @click="showEdit = true">✏️ 编辑资料</button>
      </div>
    </div>

    <div class="my-novels-section clay-card">
      <h2 class="section-title">📚 我的小说</h2>
      <div v-if="myNovels.length === 0" class="empty-state">还没有发布过小说哦</div>
      <div v-else class="novel-list">
        <div v-for="novel in myNovels" :key="novel.id" class="my-novel-item">
          <div class="novel-mini-cover">📖</div>
          <div class="novel-item-info">
            <router-link :to="'/novel/' + novel.id" class="novel-item-title">{{ novel.title }}</router-link>
            <span class="novel-item-status" :class="novel.status">{{ novel.status === 'ongoing' ? '连载中' : '已完结' }}</span>
          </div>
          <span class="novel-item-meta">⭐ {{ novel.score }} | 👁️ {{ novel.clickCount }}</span>
          <button class="clay-btn clay-btn-danger" @click="handleDelete(novel.id)" :disabled="deletingId === novel.id">
            {{ deletingId === novel.id ? '删除中...' : '🗑️ 删除' }}
          </button>
        </div>
      </div>
    </div>

    <el-dialog v-model="showEdit" title="编辑资料" width="420px" class="clay-dialog">
      <el-form :model="editForm" label-position="top">
        <el-form-item label="昵称">
          <el-input v-model="editForm.nickname" class="clay-el-input" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="editForm.email" class="clay-el-input" />
        </el-form-item>
        <el-form-item label="个人简介">
          <el-input v-model="editForm.bio" type="textarea" :rows="3" class="clay-el-input" />
        </el-form-item>
      </el-form>
      <template #footer>
        <button class="clay-btn" @click="showEdit = false">取消</button>
        <button class="clay-btn clay-btn-primary" @click="saveProfile">保存</button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { useUserStore } from "../store";
import { updateProfile } from "../api/user";
import { getMyNovels, deleteNovel } from "../api/novel";
import { ElMessage, ElMessageBox } from "element-plus";

const userStore = useUserStore();
const loading = ref(false);
const myNovels = ref([]);
const showEdit = ref(false);
const editForm = reactive({ nickname: "", email: "", bio: "" });
const deletingId = ref(null);

const fetchData = async () => {
  loading.value = true;
  try {
    await userStore.fetchProfile();
    if (userStore.user) {
      editForm.nickname = userStore.user.nickname || "";
      editForm.email = userStore.user.email || "";
      editForm.bio = userStore.user.bio || "";
    }
    const res = await getMyNovels({ page: 1, size: 50 });
    myNovels.value = res.data?.records || [];
  } finally { loading.value = false; }
};

const saveProfile = async () => {
  await updateProfile(editForm);
  ElMessage.success("保存成功");
  showEdit.value = false;
  await userStore.fetchProfile();
};

const handleDelete = async (novelId) => {
  try {
    await ElMessageBox.confirm('确定要删除这篇小说吗？此操作不可恢复。', '确认删除', {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning',
    });
    deletingId.value = novelId;
    await deleteNovel(novelId);
    ElMessage.success('删除成功');
    myNovels.value = myNovels.value.filter(n => n.id !== novelId);
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '删除失败');
  } finally {
    deletingId.value = null;
  }
};

onMounted(fetchData);
</script>

<style lang="scss" scoped>
.profile-section { padding: 32px; margin-bottom: 24px; }
.profile-header { display: flex; align-items: flex-start; gap: 24px; }
.profile-avatar { width: 100px; height: 100px; border-radius: 50%; background: linear-gradient(135deg, #fddc8a, #f9a8a8); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.avatar-icon { font-size: 40px; }
.profile-info { flex: 1; }
.profile-info h2 { font-size: 24px; margin-bottom: 8px; }
.profile-info p { color: var(--clay-text-light); font-size: 14px; margin: 4px 0; }
.join-date { font-size: 12px; color: #b0a090; }
.my-novels-section { padding: 24px; }
.section-title { font-size: 20px; font-weight: 700; margin-bottom: 16px; }
.empty-state { text-align: center; padding: 40px; color: var(--clay-text-light); }
.novel-list { display: flex; flex-direction: column; gap: 12px; }
.my-novel-item { display: flex; align-items: center; gap: 16px; padding: 12px 16px; border-radius: 12px; background: var(--clay-bg); }
.novel-mini-cover { font-size: 28px; }
.novel-item-info { flex: 1; display: flex; align-items: center; gap: 12px; }
.novel-item-title { text-decoration: none; font-weight: 600; color: var(--clay-text); }
.novel-item-title:hover { color: var(--clay-primary); }
.novel-item-status { font-size: 12px; padding: 2px 10px; border-radius: 10px; }
.novel-item-status.ongoing { background: #fde8d0; color: #e8915a; }
.novel-item-status.completed { background: #d0f0e0; color: #78b8a0; }
.novel-item-meta { font-size: 13px; color: var(--clay-text-light); }
.clay-btn-danger { background: #f9a8a8; color: #fff; font-size: 13px; padding: 6px 16px; border-radius: 50px; cursor: pointer; border: none; transition: all 0.2s; }
.clay-btn-danger:hover { background: #e87a7a; }
.clay-btn-danger:disabled { opacity: 0.6; cursor: not-allowed; }
.clay-el-input :deep(.el-input__wrapper),
.clay-el-input :deep(.el-textarea__inner) { border-radius: 12px; box-shadow: var(--clay-inset); border: none; background: var(--clay-bg); }
</style>
