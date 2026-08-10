<template>
  <div class="app-shell">
    <div class="home-top">
      <div class="city-select">
        杭州 <el-icon><ArrowDown /></el-icon>
      </div>
      <el-input
        v-model="keyword"
        clearable
        placeholder="搜索商户名"
        :prefix-icon="Search"
        @keyup.enter="handleSearch"
      />
      <button class="icon-btn profile-shortcut" type="button" @click="goProfile">
        <el-icon><User /></el-icon>
      </button>
    </div>

    <div class="page">
      <section class="category-panel">
        <div class="section-title">
          <strong>分类</strong>
          <span>已对接 /shop-type/list</span>
        </div>
        <div v-if="loadingTypes" class="list-status">正在加载分类...</div>
        <div v-else class="type-grid">
          <button v-for="type in shopTypes" :key="type.id" class="type-item" type="button" @click="toShops(type)">
            <img :src="`/imgs${type.icon}`" :alt="type.name" />
            <span>{{ type.name }}</span>
          </button>
        </div>
      </section>

      <section class="category-panel">
        <div class="section-title">
          <strong>商户搜索</strong>
          <span>已对接 /shop/of/name</span>
        </div>
        <div v-if="searching" class="list-status">正在搜索...</div>
        <el-empty v-else-if="searched && !searchResults.length" description="没有找到商户" />
        <div v-else-if="searchResults.length" class="shop-list">
          <ShopCard v-for="shop in searchResults" :key="shop.id" :shop="shop" />
        </div>
        <p v-else class="muted">
          输入商户名后回车搜索，也可以直接从分类进入列表。
        </p>
      </section>

      <section class="category-panel">
        <div class="section-title">
          <strong>热门笔记</strong>
          <span>已对接 /blog/hot</span>
        </div>
        <div v-if="blogLoading" class="list-status">正在加载笔记...</div>
        <div v-else-if="blogs.length" class="blog-grid">
          <BlogCard
            v-for="blog in blogs"
            :key="blog.id"
            :blog="blog"
            @update="updateBlog"
          />
        </div>
        <p v-else class="muted">
          还没有笔记，登录后可以从底部「发布」写第一条。
        </p>
        <div v-if="blogs.length" class="blog-more">
          <el-button v-if="!blogFinished" text type="primary" :loading="blogLoadingMore" @click="loadMoreBlogs">
            加载更多
          </el-button>
          <span v-else class="muted">没有更多笔记了</span>
        </div>
      </section>

      <section class="category-panel">
        <div class="section-title">
          <strong>关注流</strong>
          <span>已对接 /blog/of/follow</span>
        </div>
        <div v-if="!store.isLoggedIn" class="list-status">登录后可查看关注的笔记流</div>
        <div v-else-if="feedLoading" class="list-status">正在加载关注流...</div>
        <div v-else-if="feedBlogs.length" class="blog-grid">
          <BlogCard
            v-for="blog in feedBlogs"
            :key="blog.id"
            :blog="blog"
            @update="updateFeedBlog"
          />
        </div>
        <p v-else class="muted">关注用户后，这里会显示他们最新发布的笔记。</p>
        <div v-if="store.isLoggedIn && feedBlogs.length" class="blog-more">
          <el-button v-if="!feedFinished" text type="primary" :loading="feedLoadingMore" @click="loadMoreFeed">
            加载更多
          </el-button>
          <span v-else class="muted">没有更多笔记了</span>
        </div>
      </section>

      <section class="session-band">
        <div>
          <strong>{{ store.isLoggedIn ? store.displayName : '未登录' }}</strong>
          <span>{{ store.isLoggedIn ? store.maskedPhone : '登录后可查看 /user/me 信息' }}</span>
        </div>
        <el-button size="small" :type="store.isLoggedIn ? 'primary' : 'default'" @click="goProfile">
          {{ store.isLoggedIn ? '我的' : '登录' }}
        </el-button>
      </section>
    </div>

    <BottomNav current="home" />
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowDown, Search, User } from '@element-plus/icons-vue'
import BottomNav from '@/components/BottomNav.vue'
import ShopCard from '@/components/ShopCard.vue'
import BlogCard from '@/components/BlogCard.vue'
import { useSessionStore } from '@/stores/session'
import { getShopTypes, searchShops } from '@/api/shop'
import { getFollowBlogs, getHotBlogs } from '@/api/blog'

const router = useRouter()
const store = useSessionStore()

const keyword = ref('')
const shopTypes = ref([])
const loadingTypes = ref(false)
const searching = ref(false)
const searched = ref(false)
const searchResults = ref([])
const blogs = ref([])
const blogCurrent = ref(1)
const blogLoading = ref(false)
const blogLoadingMore = ref(false)
const blogFinished = ref(false)
const feedBlogs = ref([])
const feedLoading = ref(false)
const feedLoadingMore = ref(false)
const feedFinished = ref(false)
const feedLastId = ref(Date.now())
const feedOffset = ref(0)

function toShops(type) {
  router.push({
    path: '/shops',
    query: {
      typeId: type.id,
      typeName: type.name
    }
  })
}

function goProfile() {
  router.push(store.isLoggedIn ? '/profile' : '/login')
}

async function handleSearch() {
  const name = keyword.value.trim()
  if (!name) {
    ElMessage.warning('请输入商户名称')
    return
  }
  searching.value = true
  searched.value = true
  try {
    searchResults.value = await searchShops(name)
  } finally {
    searching.value = false
  }
}

async function loadBlogs(append = false) {
  if (append) {
    blogLoadingMore.value = true
  } else {
    blogLoading.value = true
  }
  try {
    const list = await getHotBlogs(blogCurrent.value)
    if (!list || !list.length) {
      blogFinished.value = true
      return
    }
    blogs.value = append ? [...blogs.value, ...list] : list
    blogCurrent.value += 1
    if (list.length < 10) {
      blogFinished.value = true
    }
  } finally {
    blogLoading.value = false
    blogLoadingMore.value = false
  }
}

async function loadMoreBlogs() {
  await loadBlogs(true)
}

function updateBlog(updatedBlog) {
  const index = blogs.value.findIndex((blog) => blog.id === updatedBlog.id)
  if (index !== -1) {
    blogs.value[index] = updatedBlog
  }
}

async function loadFeed(append = false) {
  if (!store.isLoggedIn) {
    feedBlogs.value = []
    return
  }
  if (append) {
    feedLoadingMore.value = true
  } else {
    feedLoading.value = true
  }
  try {
    const result = await getFollowBlogs({
      lastId: feedLastId.value,
      offset: append ? feedOffset.value : 0
    })
    const list = result?.list || []
    if (!list.length) {
      feedFinished.value = true
      return
    }
    feedBlogs.value = append ? [...feedBlogs.value, ...list] : list
    feedLastId.value = result.minTime || feedLastId.value
    feedOffset.value = result.offset || 0
    if (list.length < 5) {
      feedFinished.value = true
    }
  } finally {
    feedLoading.value = false
    feedLoadingMore.value = false
  }
}

async function loadMoreFeed() {
  await loadFeed(true)
}

function updateFeedBlog(updatedBlog) {
  const index = feedBlogs.value.findIndex((blog) => blog.id === updatedBlog.id)
  if (index !== -1) {
    feedBlogs.value[index] = updatedBlog
  }
}

onMounted(async () => {
  loadingTypes.value = true
  try {
    shopTypes.value = await getShopTypes()
  } finally {
    loadingTypes.value = false
  }
  loadBlogs()
  loadFeed()
})
</script>

<style scoped>
.blog-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.blog-more {
  margin-top: 12px;
  text-align: center;
}
</style>
