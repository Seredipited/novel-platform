<template>
  <div id="app">
    <AppHeader />
    <AdBanner />
    <main class="main-content">
      <router-view />
    </main>
    <AppFooter />
  </div>
</template>

<script setup>
import AppHeader from "./components/AppHeader.vue";
import AdBanner from "./components/AdBanner.vue";
import AppFooter from "./components/AppFooter.vue";
</script>

<style lang="scss">
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
  background: #f5f0eb;
  color: #5a4a3a;
}
.main-content {
  min-height: calc(100vh - 220px);
  padding: 16px 0;
}
</style>
