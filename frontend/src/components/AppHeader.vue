<template>
  <header class="header">
    <div class="header-inner page-container">
      <router-link to="/" class="logo">
        <span class="logo-icon">📚</span>
        <span class="logo-text">文澜阁</span>
      </router-link>
      <nav class="nav">
        <router-link to="/" class="nav-link">首页</router-link>
        <router-link to="/?tab=rank" class="nav-link">排行榜</router-link>
        <router-link to="/publish" class="nav-link" v-if="userStore.isLoggedIn()">发布小说</router-link>
        <router-link to="/user" class="nav-link" v-if="userStore.isLoggedIn()">个人中心</router-link>
      </nav>
      <div class="header-search">
        <el-input
          v-model="searchKeyword"
          placeholder="请输入书名或作者名"
          clearable
          class="search-input"
          @keyup.enter="handleSearch"
        >
          <template #append>
            <button class="search-btn" @click="handleSearch">搜索</button>
          </template>
        </el-input>
      </div>
      <div class="header-right">
        <template v-if="userStore.isLoggedIn()">
          <span class="user-greeting">👋 {{ userStore.user?.nickname || userStore.user?.username }}</span>
          <button class="clay-btn clay-btn-primary" @click="logout">退出</button>
        </template>
        <template v-else>
          <router-link to="/login"><button class="clay-btn">登录</button></router-link>
          <router-link to="/register"><button class="clay-btn clay-btn-primary">注册</button></router-link>
        </template>
      </div>
    </div>
  </header>
</template>

<script setup>
import { ref } from "vue";
import { useUserStore } from "../store";
import { useRouter } from "vue-router";

const userStore = useUserStore();
const router = useRouter();
const searchKeyword = ref("");

const handleSearch = () => {
  if (!searchKeyword.value.trim()) return;
  router.push({ path: "/", query: { keyword: searchKeyword.value.trim() } });
};

const logout = () => {
  userStore.logout();
  router.push("/");
};
</script>

<style lang="scss" scoped>
.header {
  background: var(--clay-card);
  box-shadow: var(--clay-shadow-sm);
  position: sticky;
  top: 0;
  z-index: 100;
  padding: 16px 0;
}
.header-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
}
.logo {
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}
.logo-icon { font-size: 42px; }
.logo-text {
  font-size: 28px;
  font-weight: 800;
  color: var(--clay-text);
  letter-spacing: 3px;
}
.nav {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}
.nav-link {
  text-decoration: none;
  color: var(--clay-text);
  font-size: 15px;
  font-weight: 500;
  padding: 10px 18px;
  border-radius: 12px;
  transition: all 0.2s;
  white-space: nowrap;
}
.nav-link:hover { background: var(--clay-bg); }
.nav-link.router-link-active {
  color: var(--clay-primary);
  font-weight: 700;
}

.header-search {
  flex: 1;
  max-width: 420px;
  min-width: 200px;
}
.search-input {
  :deep(.el-input__wrapper) {
    border-radius: 50px 0 0 50px;
    box-shadow: var(--clay-inset);
    border: none;
    background: var(--clay-bg);
    padding-left: 20px;
  }
  :deep(.el-input-group__append) {
    background: var(--clay-primary);
    color: #fff;
    border: none;
    border-radius: 0 50px 50px 0;
    padding: 0 24px;
    box-shadow: none;
  }
}
.search-btn {
  background: transparent;
  color: #fff;
  border: none;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}
.user-greeting { font-size: 14px; color: var(--clay-text); font-weight: 500; }
</style>
