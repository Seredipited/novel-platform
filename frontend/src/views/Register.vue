<template>
  <div class="auth-page page-container">
    <div class="auth-card clay-card">
      <div class="auth-header">
        <span class="auth-icon">✨</span>
        <h2>加入文澜阁</h2>
        <p>开启你的创作与阅读之旅</p>
      </div>
      <el-form :model="form" class="auth-form" @submit.prevent="handleRegister">
        <el-form-item>
          <el-input v-model="form.username" placeholder="用户名" :prefix-icon="User" class="clay-el-input" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="form.nickname" placeholder="昵称（可选）" :prefix-icon="Edit" class="clay-el-input" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="form.password" type="password" placeholder="密码" :prefix-icon="Lock" show-password class="clay-el-input" />
        </el-form-item>
        <el-form-item>
          <button type="submit" class="clay-btn clay-btn-primary auth-submit" :disabled="loading">
            {{ loading ? '注册中...' : '注册' }}
          </button>
        </el-form-item>
      </el-form>
      <p class="auth-footer">
        已有账号？<router-link to="/login">立即登录</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
import { User, Lock, Edit } from "@element-plus/icons-vue";
import { register } from "../api/user";

const router = useRouter();
const loading = ref(false);
const form = reactive({ username: "", password: "", nickname: "" });

const handleRegister = async () => {
  if (!form.username || !form.password) return;
  loading.value = true;
  try {
    await register(form);
    router.push("/login");
  } finally { loading.value = false; }
};
</script>

<style lang="scss" scoped>
.auth-page { display: flex; justify-content: center; align-items: center; min-height: 60vh; }
.auth-card { width: 420px; padding: 40px; }
.auth-header { text-align: center; margin-bottom: 32px; }
.auth-icon { font-size: 48px; }
.auth-header h2 { font-size: 24px; margin: 12px 0 4px; }
.auth-header p { color: var(--clay-text-light); font-size: 14px; }
.auth-form { margin-bottom: 16px; }
.auth-submit { width: 100%; justify-content: center; }
.auth-footer { text-align: center; color: var(--clay-text-light); font-size: 14px; }
.auth-footer a { color: var(--clay-primary); text-decoration: none; font-weight: 600; }
.clay-el-input :deep(.el-input__wrapper) { border-radius: 50px; box-shadow: var(--clay-inset); border: none; background: var(--clay-bg); }
</style>
