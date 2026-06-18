<template>
  <div class="auth-page page-container">
    <div class="auth-card clay-card">
      <div class="auth-header">
        <span class="auth-icon">🔑</span>
        <h2>欢迎回来</h2>
        <p>登录文澜阁，继续你的阅读之旅</p>
      </div>
      <el-form :model="form" class="auth-form" @submit.prevent="handleLogin">
        <el-form-item>
          <el-input v-model="form.username" placeholder="用户名" :prefix-icon="User" class="clay-el-input" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="form.password" type="password" placeholder="密码" :prefix-icon="Lock" show-password class="clay-el-input" />
        </el-form-item>
        <el-form-item>
          <button type="submit" class="clay-btn clay-btn-primary auth-submit" :disabled="loading">
            {{ loading ? '登录中...' : '登录' }}
          </button>
        </el-form-item>
      </el-form>
      <p class="auth-footer">
        还没有账号？<router-link to="/register">立即注册</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
import { User, Lock } from "@element-plus/icons-vue";
import { login } from "../api/user";
import { useUserStore } from "../store";

const router = useRouter();
const userStore = useUserStore();
const loading = ref(false);
const form = reactive({ username: "", password: "" });

const handleLogin = async () => {
  if (!form.username || !form.password) return;
  loading.value = true;
  try {
    const res = await login(form);
    userStore.setToken(res.data.token);
    await userStore.fetchProfile();
    router.push("/");
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
