<template>
  <div class="page-container home">
    <!-- 分类导航条 -->
    <section class="category-bar">
      <button
        v-for="cat in categories"
        :key="cat.id"
        class="cat-btn"
        :class="{ active: currentCategory === cat.id }"
        @click="filterByCategory(cat.id)"
      >{{ cat.name }}</button>
      <button class="cat-btn" :class="{ active: !currentCategory }" @click="filterByCategory(null)">全部</button>
    </section>

    <!-- 排行榜/小说列表 -->
    <section class="novels-section">
      <div class="section-header">
        <h2 class="section-title">📖 小说推荐</h2>
        <div class="sort-tabs">
          <button
            v-for="s in sortOptions"
            :key="s.value"
            class="sort-btn"
            :class="{ active: sortBy === s.value }"
            @click="changeSort(s.value)"
          >{{ s.label }}</button>
        </div>
      </div>
      <div class="novel-grid" v-loading="loading">
        <NovelCard v-for="novel in novelList" :key="novel.id" :novel="novel" />
      </div>
      <div v-if="!loading && novelList.length === 0" class="empty-state">
        <p>😴 还没有小说哦，快来发布第一本吧！</p>
      </div>
      <div class="pagination-wrap" v-if="total > size">
        <el-pagination background layout="prev, pager, next" :total="total" :page-size="size" v-model:current-page="page" @current-change="fetchNovels" />
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";
import { useRoute } from "vue-router";
import { getNovelList, getCategories } from "../api/novel";
import NovelCard from "../components/NovelCard.vue";

const route = useRoute();
const novels = ref([]);
const novelList = ref([]);
const categories = ref([]);
const keyword = ref("");
const currentCategory = ref(null);
const sortBy = ref("favorite");
const page = ref(1);
const size = ref(12);
const total = ref(0);
const loading = ref(false);

const sortOptions = [
  { label: "最热", value: "favorite" },
  { label: "评分", value: "score" },
  { label: "最新", value: "newest" },
];

const fetchCategories = async () => {
  const res = await getCategories();
  categories.value = res.data || [];
};

const fetchNovels = async () => {
  loading.value = true;
  try {
    const params = { page: page.value, size: size.value, sortBy: sortBy.value };
    if (currentCategory.value) params.categoryId = currentCategory.value;
    if (keyword.value) params.keyword = keyword.value;
    const res = await getNovelList(params);
    novelList.value = res.data?.records || [];
    total.value = res.data?.total || 0;
  } finally {
    loading.value = false;
  }
};

const search = () => { page.value = 1; fetchNovels(); };
const filterByCategory = (id) => { currentCategory.value = id; page.value = 1; fetchNovels(); };
const changeSort = (s) => { sortBy.value = s; page.value = 1; fetchNovels(); };

// 监听路由 query 变化（来自顶部搜索框）
watch(() => route.query.keyword, (val) => {
  if (val !== undefined) {
    keyword.value = val || "";
    page.value = 1;
    fetchNovels();
  }
}, { immediate: true });

onMounted(() => { fetchCategories(); fetchNovels(); });
</script>

<style lang="scss" scoped>
.category-bar {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  padding: 16px 0;
  margin-bottom: 20px;
  border-bottom: 2px solid #e8e0d8;
}
.cat-btn {
  padding: 8px 22px;
  border-radius: 50px;
  border: none;
  background: transparent;
  cursor: pointer;
  font-size: 15px;
  font-weight: 500;
  color: var(--clay-text);
  transition: all 0.2s;
}
.cat-btn:hover { color: var(--clay-primary); }
.cat-btn.active {
  background: var(--clay-primary);
  color: #fff;
  font-weight: 700;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.section-title { font-size: 22px; font-weight: 700; }

.sort-tabs { display: flex; gap: 8px; }
.sort-btn {
  padding: 6px 16px;
  border-radius: 20px;
  border: none;
  background: var(--clay-bg);
  cursor: pointer;
  font-size: 14px;
  color: var(--clay-text);
}
.sort-btn.active { background: var(--clay-primary); color: #fff; }

.novel-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 18px;
}
.empty-state { text-align: center; padding: 60px; font-size: 18px; color: var(--clay-text-light); }
.pagination-wrap { display: flex; justify-content: center; margin-top: 32px; }
</style>
