<template>
  <div class="app-shell">
    <div class="page">
      <div class="topbar">
        <button class="ghost-btn" @click="router.push('/')">返回</button>
        <div class="topbar-title">本地登录态</div>
        <span></span>
      </div>

      <div class="card">
        <p class="eyebrow">SESSION SNAPSHOT</p>
        <h2 style="margin: 0 0 12px;">后端真实用户信息</h2>
        <p class="muted">
          `/user/me` 返回当前登录用户，`/user/info/{id}` 返回资料详情。
        </p>
        <div v-if="user" class="user-row" style="margin-top: 16px;">
          <img v-if="user.icon" class="avatar" :src="user.icon" alt="">
          <div v-else class="avatar avatar-fallback">{{ avatarChar }}</div>
          <div class="user-meta">
            <strong>{{ store.displayName }}</strong>
            <span class="muted">{{ store.maskedPhone }}</span>
          </div>
        </div>
        <div class="stack" style="margin-top: 18px;">
          <div class="row-between">
            <span>昵称</span>
            <strong>{{ store.displayName }}</strong>
          </div>
          <div class="row-between">
            <span>手机号</span>
            <strong>{{ store.maskedPhone }}</strong>
          </div>
          <div class="row-between">
            <span>用户 ID</span>
            <strong>{{ user?.id ?? '未知' }}</strong>
          </div>
          <div class="row-between">
            <span>登录时间</span>
            <strong>{{ loginTime }}</strong>
          </div>
        </div>
      </div>

      <div class="card">
        <p class="eyebrow">USER INFO</p>
        <h2 style="margin: 0 0 12px;">资料详情</h2>
        <div v-if="detail" class="stack">
          <div class="row-between">
            <span>城市</span>
            <strong>{{ detail.city || '未设置' }}</strong>
          </div>
          <div class="row-between">
            <span>粉丝</span>
            <strong>{{ detail.fans ?? 0 }}</strong>
          </div>
          <div class="row-between">
            <span>关注</span>
            <strong>{{ detail.followee ?? 0 }}</strong>
          </div>
          <div class="row-between">
            <span>简介</span>
            <strong class="wrap">{{ detail.introduce || '未设置' }}</strong>
          </div>
        </div>
        <p v-else class="muted">还没有资料记录，第一次查看时会自动创建。</p>
      </div>

      <div class="card">
        <strong>当前 token</strong>
        <div class="code-box" style="margin-top: 12px;">
          {{ shortToken }}
        </div>
      </div>

      <el-button type="danger" plain style="margin-top: 16px; width: 100%;" @click="handleLogout">
        退出登录
      </el-button>
    </div>

    <BottomNav current="profile" />
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import BottomNav from '@/components/BottomNav.vue'
import { useSessionStore } from '@/stores/session'
import { getUserDetail } from '@/api/user'

const router = useRouter()
const store = useSessionStore()

const user = ref(null)
const detail = ref(null)

const avatarChar = computed(() => {
  const name = store.displayName || '用'
  return name.trim().charAt(0).toUpperCase()
})

const loginTime = computed(() => {
  if (!store.session?.loginAt) {
    return '未知'
  }
  return store.session.loginAt.replace('T', ' ').slice(0, 19)
})

const shortToken = computed(() => {
  const token = store.token || ''
  if (!token) {
    return '无 token'
  }
  if (token.length < 32) {
    return token
  }
  return `${token.slice(0, 12)} ... ${token.slice(-10)}`
})

async function loadUser() {
  try {
    user.value = await store.fetchMe()
  } catch (error) {
    ElMessage.error('获取用户信息失败')
    router.push('/login')
    return
  }
  if (!user.value?.id) {
    return
  }
  try {
    detail.value = await getUserDetail(user.value.id)
  } catch (error) {
    // 详情接口失败不影响主页面展示
  }
}

async function handleLogout() {
  try {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
  } catch {
    return
  }
  await store.logout()
  ElMessage.success('已退出登录')
  router.push('/login')
}

onMounted(loadUser)
</script>

<style scoped>
.user-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.avatar {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  object-fit: cover;
  background: #fff2e9;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-fallback {
  color: #d95519;
  font-size: 20px;
  font-weight: 700;
}

.user-meta {
  display: grid;
  gap: 2px;
}

.wrap {
  max-width: 220px;
  text-align: right;
  word-break: break-all;
}
</style>
