<template>
  <div class="nav-bar">
    <button class="nav-item" :class="{ active: current === 'home' }" @click="router.push('/')">
      <el-icon><House /></el-icon>
      <span>首页</span>
    </button>
    <button class="nav-item" :class="{ active: current === 'login' }" @click="router.push('/login')">
      <el-icon><Key /></el-icon>
      <span>登录</span>
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
import { House, Key, User } from '@element-plus/icons-vue'
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
</script>
