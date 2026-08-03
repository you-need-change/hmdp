import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { getMe, logout as logoutApi } from '@/api/user'

const SESSION_KEY = 'stage1-user-session'
const TOKEN_KEY = 'stage1-user-token'

function readJson(key) {
  const raw = sessionStorage.getItem(key)
  if (!raw) {
    return null
  }
  try {
    return JSON.parse(raw)
  } catch {
    sessionStorage.removeItem(key)
    return null
  }
}

export const useSessionStore = defineStore('session', () => {
  const token = ref(sessionStorage.getItem(TOKEN_KEY) || '')
  const session = ref(readJson(SESSION_KEY))

  const isLoggedIn = computed(() => !!token.value)
  const maskedPhone = computed(() => {
    const phone = session.value?.phone || ''
    return phone ? `${phone.slice(0, 3)}****${phone.slice(-4)}` : ''
  })

  const displayName = computed(() => {
    if (session.value?.nickName) {
      return session.value.nickName
    }
    const phone = session.value?.phone || ''
    return phone ? `用户 ${phone.slice(-4)}` : '已登录用户'
  })

  function saveLogin({ phone, token: loginToken }) {
    token.value = loginToken
    session.value = {
      phone,
      loginAt: new Date().toISOString()
    }
    sessionStorage.setItem(TOKEN_KEY, loginToken)
    sessionStorage.setItem(SESSION_KEY, JSON.stringify(session.value))
  }

  async function fetchMe() {
    if (!token.value) {
      return null
    }
    const user = await getMe()
    if (!user) {
      return null
    }
    session.value = {
      ...(session.value || {}),
      ...user
    }
    sessionStorage.setItem(SESSION_KEY, JSON.stringify(session.value))
    return user
  }

  async function logout() {
    try {
      if (token.value) {
        await logoutApi()
      }
    } catch (error) {
      // 后端登出失败也继续清理本地登录态
    }
    token.value = ''
    session.value = null
    sessionStorage.removeItem(TOKEN_KEY)
    sessionStorage.removeItem(SESSION_KEY)
  }

  return {
    token,
    session,
    isLoggedIn,
    maskedPhone,
    displayName,
    saveLogin,
    fetchMe,
    logout
  }
})
