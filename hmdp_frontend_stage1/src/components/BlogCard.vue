<template>
  <div class="blog-card" @click="toDetail">
    <div class="blog-cover">
      <img :src="cover" :alt="blog.title" />
    </div>
    <div class="blog-body">
      <h4 class="blog-title">{{ blog.title || '未命名笔记' }}</h4>
      <div class="blog-footer">
        <div class="blog-author">
          <img v-if="blog.icon" :src="blog.icon" alt="" class="author-icon" />
          <span v-else class="author-icon author-fallback">{{ authorChar }}</span>
          <span class="author-name">{{ blog.name || '未知用户' }}</span>
        </div>
        <div class="blog-stats">
          <button class="stat-btn" type="button" @click.stop="handleLike">
            <svg class="like-icon" viewBox="0 0 1024 1024" width="14" height="14">
              <path
                d="M160 944c0 8.8-7.2 16-16 16h-32c-26.5 0-48-21.5-48-48V528c0-26.5 21.5-48 48-48h32c8.8 0 16 7.2 16 16v448zM96 416c-53 0-96 43-96 96v416c0 53 43 96 96 96h96c17.7 0 32-14.3 32-32V448c0-17.7-14.3-32-32-32H96zM505.6 64c16.2 0 26.4 8.7 31 13.9 4.6 5.2 12.1 16.3 10.3 32.4l-23.5 203.4c-4.9 42.2 8.6 84.6 36.8 116.4 28.3 31.7 68.9 49.9 111.4 49.9h271.2c6.6 0 10.8 3.3 13.2 6.1s5 7.5 4 14l-48 303.4c-6.9 43.6-29.1 83.4-62.7 112C815.8 944.2 773 960 728.9 960h-317c-33.1 0-59.9-26.8-59.9-59.9v-455c0-6.1 1.7-12 5-17.1 69.5-109 106.4-234.2 107-364h41.6z m0-64h-44.9C427.2 0 400 27.2 400 60.7c0 127.1-39.1 251.2-112 355.3v484.1c0 68.4 55.5 123.9 123.9 123.9h317c122.7 0 227.2-89.3 246.3-210.5l47.9-303.4c7.8-49.4-30.4-94.1-80.4-94.1H671.6c-50.9 0-90.5-44.4-84.6-95l23.5-203.4C617.7 55 568.7 0 505.6 0z"
                :fill="blog.isLike ? '#f05e29' : '#8e847f'"
              />
            </svg>
            <span :class="{ liked: blog.isLike }">{{ blog.liked || 0 }}</span>
          </button>
          <div class="stat-btn">
            <el-icon><ChatDotRound /></el-icon>
            <span>{{ blog.comments || 0 }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ChatDotRound } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { likeBlog } from '@/api/blog'
import { useSessionStore } from '@/stores/session'

const props = defineProps({
  blog: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update'])

const router = useRouter()
const session = useSessionStore()

const blog = ref({ ...props.blog })

watch(
  () => props.blog,
  (value) => {
    blog.value = { ...value }
  },
  { deep: true }
)

const cover = computed(() => {
  const raw = blog.value.images
  if (raw) {
    const images = Array.isArray(raw) ? raw : String(raw).split(',').filter(Boolean)
    if (images.length) {
      return images[0]
    }
  }
  return '/imgs/blogs/blog1.jpg'
})

const authorChar = computed(() => {
  const name = blog.value.name || '未'
  return name.trim().charAt(0).toUpperCase()
})

function toDetail() {
  router.push(`/blog/${blog.value.id}`)
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
  emit('update', { ...blog.value })
}
</script>

<style scoped>
.blog-card {
  overflow: hidden;
  border: 1px solid #f2e7df;
  border-radius: 8px;
  background: #fff;
  box-shadow: 0 10px 24px rgba(65, 39, 23, 0.06);
  cursor: pointer;
}

.blog-cover {
  aspect-ratio: 16 / 10;
  background: #fff2e9;
}

.blog-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.blog-body {
  padding: 10px;
}

.blog-title {
  margin: 0 0 10px;
  font-size: 14px;
  line-height: 1.45;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.blog-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.blog-author {
  min-width: 0;
  display: flex;
  align-items: center;
  gap: 6px;
}

.author-icon {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  object-fit: cover;
  background: #fff2e9;
}

.author-fallback {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #d95519;
  font-size: 11px;
  font-weight: 700;
}

.author-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #776d67;
  font-size: 12px;
}

.blog-stats {
  display: flex;
  align-items: center;
  gap: 10px;
}

.stat-btn {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  border: none;
  background: transparent;
  color: #8e847f;
  font-size: 12px;
  cursor: pointer;
}

.stat-btn .liked {
  color: #f05e29;
}

.like-icon {
  transition: transform 0.2s;
}

.stat-btn:active .like-icon {
  transform: scale(1.2);
}
</style>
