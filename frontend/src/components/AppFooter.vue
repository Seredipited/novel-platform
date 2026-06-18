<template>
  <footer class="footer">
    <div class="page-container footer-inner">
      <div class="footer-info">
        <span class="footer-logo">📚 文澜阁</span>
        <p>一个充满创意与温暖的小说阅读平台</p>
      </div>
      <div class="footer-links">
        <span>关于我们</span>
        <span>帮助中心</span>
        <span>用户协议</span>
      </div>
      <div class="footer-copy">
        &copy; 2026 文澜阁 Novel Platform. All rights reserved.
      </div>
    </div>
  </footer>
</template>

<style lang="scss" scoped>
.footer { background: var(--clay-card); box-shadow: 0 -4px 8px rgba(0,0,0,0.05); padding: 32px 0 20px; margin-top: 40px; }
.footer-inner { text-align: center; display: flex; flex-direction: column; gap: 16px; }
.footer-logo { font-size: 20px; font-weight: 700; }
.footer-info p { color: var(--clay-text-light); font-size: 14px; margin-top: 4px; }
.footer-links { display: flex; justify-content: center; gap: 24px; color: var(--clay-text-light); font-size: 14px; cursor: pointer; }
.footer-links span:hover { color: var(--clay-primary); }
.footer-copy { font-size: 12px; color: var(--clay-text-light); border-top: 1px solid #e8e0d8; padding-top: 16px; }
</style>
