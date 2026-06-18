<template>
  <router-link :to="'/novel/' + novel.id" class="novel-card clay-card">
    <div class="novel-cover">
      <img v-if="novel.coverImg" :src="novel.coverImg" :alt="novel.title" class="cover-img" />
      <span v-else class="cover-placeholder">📖</span>
    </div>
    <div class="novel-info">
      <h3 class="novel-title">{{ novel.title }}</h3>
      <p class="novel-author">✍️ {{ novel.author }}</p>
      <p class="novel-desc">{{ novel.description?.substring(0, 60) }}{{ novel.description?.length > 60 ? '...' : '' }}</p>
      <div class="novel-meta">
        <span class="meta-item">⭐ {{ novel.score || '0.0' }}</span>
        <span class="meta-item">👁️ {{ novel.clickCount || 0 }}</span>
        <span class="meta-item status" :class="novel.status">{{ novel.status === 'ongoing' ? '连载中' : '已完结' }}</span>
      </div>
    </div>
  </router-link>
</template>

<script setup>
defineProps({ novel: { type: Object, required: true } });
</script>

<style lang="scss" scoped>
.novel-card { display: flex; gap: 16px; text-decoration: none; padding: 16px; transition: transform 0.2s; }
.novel-card:hover { transform: translateY(-4px); }
.novel-cover { width: 100px; height: 140px; border-radius: 12px; background: linear-gradient(135deg, #fddc8a, #f9a8a8); display: flex; align-items: center; justify-content: center; flex-shrink: 0; overflow: hidden; }
.cover-img { width: 100%; height: 100%; object-fit: cover; }
.cover-placeholder { font-size: 40px; }
.novel-info { flex: 1; min-width: 0; }
.novel-title { font-size: 18px; font-weight: 700; color: var(--clay-text); margin-bottom: 4px; }
.novel-author { font-size: 13px; color: var(--clay-text-light); margin-bottom: 8px; }
.novel-desc { font-size: 13px; color: #8a7a6a; line-height: 1.5; margin-bottom: 10px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.novel-meta { display: flex; gap: 16px; font-size: 13px; color: var(--clay-text-light); }
.status.ongoing { color: #e8915a; }
.status.completed { color: #78b8a0; }
</style>
