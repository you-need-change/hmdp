<template>
  <div class="app-shell">
    <div class="page">
      <div class="topbar">
        <button class="ghost-btn" @click="router.push('/')">返回</button>
        <div class="topbar-title">验证码登录</div>
        <button class="ghost-btn" @click="router.push('/password-login')">密码登录</button>
      </div>

      <div class="card">
        <p class="eyebrow">LOGIN FLOW</p>
        <h2 style="margin: 0 0 10px;">手机号快捷登录</h2>
        <p class="muted">这里只接当前后端已经实现的验证码登录主流程。</p>

        <div class="form-grid" style="margin-top: 18px;">
          <el-input v-model="form.phone" size="large" placeholder="请输入手机号" />
          <div class="row-between">
            <el-input v-model="form.code" size="large" placeholder="请输入验证码" />
            <el-button :disabled="sending || countdown > 0" @click="handleSendCode">
              {{ countdown > 0 ? `${countdown}s` : '发验证码' }}
            </el-button>
          </div>
          <label class="hint">
            <input v-model="agreed" type="checkbox" />
            我已知晓当前阶段只做验证码登录演示
          </label>
          <el-button type="primary" size="large" @click="handleLogin">登录</el-button>
        </div>

        <div v-if="devCode" class="dev-code" style="margin-top: 14px;">
          当前开发环境验证码：{{ devCode }}
        </div>
      </div>
    </div>

    <BottomNav current="login" />
  </div>
</template>

<script setup>
import { onBeforeUnmount, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import BottomNav from '@/components/BottomNav.vue'
import { sendCode, loginByCode } from '@/api/user'
import { useSessionStore } from '@/stores/session'

const router = useRouter()
const store = useSessionStore()

const form = reactive({
  phone: '',
  code: ''
})
const sending = ref(false)
const countdown = ref(0)
const agreed = ref(false)
const devCode = ref('')
let timer = null

function startCountdown() {
  countdown.value = 60
  timer = setInterval(() => {
    countdown.value -= 1
    if (countdown.value <= 0) {
      clearInterval(timer)
      timer = null
    }
  }, 1000)
}

async function handleSendCode() {
  if (!/^1[3-9]\d{9}$/.test(form.phone)) {
    ElMessage.warning('请输入正确的手机号')
    return
  }

  sending.value = true
  try {
    const code = await sendCode(form.phone)
    devCode.value = code || ''
    ElMessage.success('验证码已发送')
    startCountdown()
  } finally {
    sending.value = false
  }
}

async function handleLogin() {
  if (!agreed.value) {
    ElMessage.warning('先勾选说明')
    return
  }
  if (!/^1[3-9]\d{9}$/.test(form.phone) || !form.code) {
    ElMessage.warning('请填写手机号和验证码')
    return
  }

  const token = await loginByCode(form)
  store.saveLogin({
    phone: form.phone,
    token
  })
  try {
    await store.fetchMe()
  } catch (error) {
    // 拿不到用户信息也不阻断登录，登录态页会再拉一次
  }
  ElMessage.success('登录成功')
  router.push('/profile')
}

onBeforeUnmount(() => {
  if (timer) {
    clearInterval(timer)
  }
})
</script>
