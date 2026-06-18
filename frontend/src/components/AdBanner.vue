<template>
  <div class="ad-banner" v-if="banners.length > 0">
    <el-carousel :interval="4000" arrow="always" height="300px" indicator-position="outside">
      <el-carousel-item v-for="(banner, index) in banners" :key="index">
        <div
          class="banner-slide"
          :style="{ background: banner.bg }"
          @click="handleClick(banner)"
        >
          <div class="banner-content page-container">
            <div class="banner-text">
              <h3 class="banner-title">{{ banner.title }}</h3>
              <p class="banner-desc">{{ banner.desc }}</p>
            </div>
            <div class="banner-img" v-html="banner.icon"></div>
          </div>
        </div>
      </el-carousel-item>
    </el-carousel>
  </div>
</template>

<script setup>
import { ref } from "vue";

const banners = ref([
  {
    title: "2026年第八届文澜阁作者大会",
    desc: "匠心打磨好作品，百万奖金等你拿",
    icon: '<span style="font-size:80px">🏆</span>',
    bg: "linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)",
  },
  {
    title: "新书推荐 · 热血玄幻",
    desc: "《星辰变》续作震撼上线，千万读者追更中",
    icon: '<span style="font-size:80px">⚔️</span>',
    bg: "linear-gradient(135deg, #2d1b4e 0%, #4a1942 50%, #6b2048 100%)",
  },
  {
    title: "签约作者招募计划",
    desc: "高保底、无全勤限制，优质作品优先推荐位",
    icon: '<span style="font-size:80px">✍️</span>',
    bg: "linear-gradient(135deg, #134e5e 0%, #71b280 100%)",
  },
]);

const handleClick = (banner) => {
  if (banner.link) window.open(banner.link);
};
</script>

<style lang="scss" scoped>
.ad-banner {
  margin-bottom: 24px;
  border-radius: var(--clay-border-radius);
  overflow: hidden;
}
.banner-slide {
  height: 100%;
  cursor: pointer;
  display: flex;
  align-items: center;
  position: relative;
}
.banner-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  height: 100%;
}
.banner-text { color: #fff; }
.banner-title {
  font-size: 32px;
  font-weight: 800;
  margin-bottom: 12px;
  text-shadow: 0 2px 10px rgba(0,0,0,0.3);
}
.banner-desc {
  font-size: 16px;
  opacity: 0.85;
  text-shadow: 0 1px 6px rgba(0,0,0,0.2);
}
.banner-img { flex-shrink: 0; }

/* 覆盖 element-plus 轮播指示器样式 */
:deep(.el-carousel__indicators--outside) {
  bottom: -8px;
  .el-carousel__button {
    background-color: rgba(249, 168, 168, 0.4);
    &.is-active { background-color: #f9a8a8; }
  }
}
:deep(.el-carousel__arrow) {
  background: rgba(255,255,255,0.25);
  color: #333;
  &:hover { background: rgba(255,255,255,0.45); }
}
</style>
