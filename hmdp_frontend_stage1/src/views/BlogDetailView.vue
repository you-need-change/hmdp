<template>
  <div class="app-shell">
    <HeaderBar title="笔记详情" />

    <div class="page compact">
      <div v-if="loading" class="list-status">正在加载笔记...</div>
      <el-empty v-else-if="!blog" description="笔记不存在" />

      <template v-else>
        <section v-if="images.length" class="swiper-section">
          <el-carousel height="260px" :interval="4000" arrow="never">
            <el-carousel-item v-for="(image, index) in images" :key="index">
              <img :src="image" :alt="blog.title" />
            </el-carousel-item>
          </el-carousel>
        </section>

        <section class="author-section">
          <div class="author-info">
            <img v-if="blog.icon" :src="blog.icon" alt="" class="avatar" />
            <div v-else class="avatar avatar-fallback">{{ authorChar }}</div>
          <div class="author-meta">
              <strong>{{ blog.name || '未知用户' }}</strong>
              <span>{{ formatTime(blog.createTime) }}</span>
            </div>
          </div>
          <span v-if="isSelf" class="self-tag">我</span>
          <el-button
            v-else
            size="small"
            :type="followed ? 'default' : 'primary'"
            plain
            @click="handleFollow"
          >
            {{ followed ? '已关注' : '关注' }}
          </el-button>
        </section>

        <section class="blog-content">
          <h1 class="blog-title">{{ blog.title || '未命名笔记' }}</h1>
          <p class="content-text">{{ blog.content || '这个人还没有写内容~' }}</p>
        </section>

        <section v-if="shop" class="shop-card" @click="router.push(`/shop/${shop.id}`)">
          <img :src="shopCover" :alt="shop.name" class="shop-cover" />
          <div class="shop-info">
            <strong>{{ shop.name }}</strong>
            <el-rate :model-value="shopScore" disabled size="small" />
            <span v-if="shop.avgPrice" class="price">￥{{ shop.avgPrice }}/人</span>
          </div>
          <el-icon class="shop-arrow"><ArrowRight /></el-icon>
        </section>

        <section class="likes-section">
          <div class="section-title">
            <strong>点赞用户</strong>
            <span>已对接 /blog/likes/{id}</span>
          </div>
          <div v-if="likes.length" class="like-users">
            <img
              v-for="user in likes"
              :key="user.id"
              :src="user.icon || '/imgs/icons/default-icon.png'"
              :alt="user.nickName"
              class="like-avatar"
            />
            <span>{{ blog.liked || 0 }} 人点赞</span>
          </div>
          <p v-else class="muted">暂无点赞用户</p>
        </section>
      </template>
    </div>

    <div v-if="blog" class="action-bar">
      <button class="action-btn" type="button" @click="handleLike">
        <svg viewBox="0 0 1024 1024" width="24" height="24">
          <path
            d="M160 944c0 8.8-7.2 16-16 16h-32c-26.5 0-48-21.5-48-48V528c0-26.5 21.5-48 48-48h32c8.8 0 16 7.2 16 16v448zM96 416c-53 0-96 43-96 96v416c0 53 43 96 96 96h96c17.7 0 32-14.3 32-32V448c0-17.7-14.3-32-32-32H96zM505.6 64c16.2 0 26.4 8.7 31 13.9 4.6 5.2 12.1 16.3 10.3 32.4l-23.5 203.4c-4.9 42.2 8.6 84.6 36.8 116.4 28.3 31.7 68.9 49.9 111.4 49.9h271.2c6.6 0 10.8 3.3 13.2 6.1s5 7.5 4 14l-48 303.4c-6.9 43.6-29.1 83.4-62.7 112C815.8 944.2 773 960 728.9 960h-317c-33.1 0-59.9-26.8-59.9-59.9v-455c0-6.1 1.7-12 5-17.1 69.5-109 106.4-234.2 107-364h41.6z m0-64h-44.9C427.2 0 400 27.2 400 60.7c0 127.1-39.1 251.2-112 355.3v484.1c0 68.4 55.5 123.9 123.9 123.9h317c122.7 0 227.2-89.3 246.3-210.5l47.9-303.4c7.8-49.4-30.4-94.1-80.4-94.1H671.6c-50.9 0-90.5-44.4-84.6-95l23.5-203.4C617.7 55 568.7 0 505.6 0z"
            :fill="blog.isLike ? '#f05e29' : '#8e847f'"
          />
        </svg>
        <span :class="{ liked: blog.isLike }">{{ blog.liked || 0 }}</span>
      </button>
      <div class="action-btn muted">
        <el-icon :size="24"><ChatDotRound /></el-icon>
        <span>{{ blog.comments || 0 }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowRight, ChatDotRound } from '@element-plus/icons-vue'
import HeaderBar from '@/components/HeaderBar.vue'
import { getBlogById, getBlogLikes, likeBlog } from '@/api/blog'
import { followUser, isFollowed } from '@/api/follow'
import { getShopById } from '@/api/shop'
import { useSessionStore } from '@/stores/session'

const route = useRoute()
const router = useRouter()
const session = useSessionStore()

const blog = ref(null)
const shop = ref(null)
const likes = ref([])
const followed = ref(false)
const loading = ref(false)

const images = computed(() => {
  const raw = blog.value?.images
  if (!raw) {
    return []
  }
  if (Array.isArray(raw)) {
    return raw.filter(Boolean)
  }
  return String(raw)
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean)
})

const authorChar = computed(() => {
  const name = blog.value?.name || '未'
  return name.trim().charAt(0).toUpperCase()
})

const isSelf = computed(() => {
  return session.session?.id === blog.value?.userId
})

const shopCover = computed(() => {
  const raw = shop.value?.images
  if (!raw) {
    return '/imgs/types/ms.png'
  }
  const list = Array.isArray(raw) ? raw : String(raw).split(',').filter(Boolean)
  return list[0] || '/imgs/types/ms.png'
})

const shopScore = computed(() => Number(shop.value?.score || 0) / 10)

function formatTime(value) {
  if (!value) {
    return ''
  }
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) {
    return String(value)
  }
  const pad = (val) => String(val).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

async function loadBlog() {
  const data = await getBlogById(route.params.id)
  blog.value = data
  if (data.shopId) {
    try {
      shop.value = await getShopById(data.shopId)
    } catch (error) {
      // 关联商户加载失败不阻断详情展示
    }
  }
  await loadSocialState()
}

async function loadSocialState() {
  if (!session.isLoggedIn || !blog.value?.id) {
    likes.value = []
    followed.value = false
    return
  }
  try {
    likes.value = await getBlogLikes(blog.value.id)
  } catch (error) {
    likes.value = []
  }
  if (!isSelf.value && blog.value?.userId) {
    try {
      followed.value = await isFollowed(blog.value.userId)
    } catch (error) {
      followed.value = false
    }
  }
}

async function handleFollow() {
  if (!session.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  await followUser(blog.value.userId, !followed.value)
  followed.value = !followed.value
  ElMessage.success(followed.value ? '已关注' : '已取消关注')
}

async function handleLike() {
  if (!session.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }

  const liked = await likeBlog(blog.value.id)
  blog.value.isLike = liked
  blog.value.liked = Math.max(
    0,
    Number(blog.value.liked || 0) + (liked ? 1 : -1)
  )
  await loadSocialState()
}

onMounted(async () => {
  loading.value = true
  try {
    await loadBlog()
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.page.compact {
  padding-bottom: 90px;
}

.swiper-section {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 10px 24px rgba(65, 39, 23, 0.06);
}

.swiper-section img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.author-section {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 16px;
  margin-top: 14px;
  border-radius: 8px;
  background: #fff;
  box-shadow: 0 10px 24px rgba(65, 39, 23, 0.06);
}

.author-info {
  min-width: 0;
  display: flex;
  align-items: center;
  gap: 10px;
}

.avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  object-fit: cover;
  background: #fff2e9;
}

.avatar-fallback {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #d95519;
  font-size: 18px;
  font-weight: 700;
}

.author-meta {
  min-width: 0;
  display: grid;
  gap: 3px;
}

.author-meta span {
  color: #8e847f;
  font-size: 12px;
}

.self-tag {
  padding: 3px 10px;
  border-radius: 999px;
  background: #fff2e9;
  color: #d95519;
  font-size: 12px;
  font-weight: 700;
}

.blog-content {
  padding: 16px;
  margin-top: 14px;
  border-radius: 8px;
  background: #fff;
  box-shadow: 0 10px 24px rgba(65, 39, 23, 0.06);
}

.blog-title {
  margin: 0 0 10px;
  font-size: 20px;
}

.content-text {
  margin: 0;
  color: #4d4038;
  font-size: 14px;
  line-height: 1.8;
  white-space: pre-wrap;
  word-break: break-word;
}

.shop-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  margin-top: 14px;
  border-radius: 8px;
  background: #fff;
  box-shadow: 0 10px 24px rgba(65, 39, 23, 0.06);
  cursor: pointer;
}

.shop-cover {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
  background: #fff2e9;
}

.shop-info {
  min-width: 0;
  flex: 1;
  display: grid;
  gap: 4px;
}

.price {
  color: #e85c28;
  font-size: 12px;
  font-weight: 700;
}

.shop-arrow {
  color: #8e847f;
}

.action-bar {
  position: fixed;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 100%;
  max-width: 540px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 40px;
  background: rgba(255, 255, 255, 0.96);
  border-top: 1px solid #f0e2d8;
  z-index: 10;
}

.action-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border: none;
  background: transparent;
  color: #6e6560;
  font-size: 14px;
  cursor: pointer;
}

.action-btn .liked {
  color: #f05e29;
}
</style>
