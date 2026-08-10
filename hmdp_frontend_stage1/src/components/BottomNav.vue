<template>
  <div class="nav-bar">
    <button class="nav-item" :class="{ active: current === 'home' }" @click="router.push('/')">
      <el-icon><House /></el-icon>
      <span>首页</span>
    </button>
    <button class="nav-item publish-item" type="button" @click="goPublish">
      <img src="/imgs/add.png" alt="发布" class="publish-icon" />
      <span>发布</span>
    </button>
    <button class="nav-item" :class="{ active: current === 'profile' }" @click="goProfile">
      <el-icon><User /></el-icon>
      <span>我的</span>
    </button>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { House, User } from '@element-plus/icons-vue'
import { useSessionStore } from '@/stores/session'

const props = defineProps({
  current: {
    type: String,
    required: true
  }
})

const router = useRouter()
const store = useSessionStore()

function goProfile() {
  if (!store.isLoggedIn) {
    ElMessage.warning('请先完成验证码登录')
    router.push('/login')
    return
  }
  router.push('/profile')
}

function goPublish() {
  if (!store.isLoggedIn) {
    ElMessage.warning('请先完成验证码登录')
    router.push('/login')
    return
  }
  router.push('/blog-edit')
}
</script>

<style scoped>
.publish-icon {
  width: 26px;
  height: 26px;
  object-fit: contain;
}

.publish-item {
  color: #f05e29;
}
</style>
