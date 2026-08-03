import { createRouter, createWebHistory } from 'vue-router'
import { useSessionStore } from '@/stores/session'

const routes = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/views/HomeView.vue'),
    meta: { title: '黑马点评' }
  },
  {
    path: '/shops',
    name: 'shops',
    component: () => import('@/views/ShopListView.vue'),
    meta: { title: '商户列表' }
  },
  {
    path: '/shop/:id',
    name: 'shop-detail',
    component: () => import('@/views/ShopDetailView.vue'),
    meta: { title: '商户详情' }
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/LoginView.vue'),
    meta: { title: '验证码登录' }
  },
  {
    path: '/profile',
    name: 'profile',
    component: () => import('@/views/ProfileView.vue'),
    meta: { title: '登录态' }
  },
  {
    path: '/password-login',
    name: 'password-login',
    component: () => import('@/views/PasswordLoginView.vue'),
    meta: { title: '密码登录' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})

router.beforeEach((to) => {
  document.title = to.meta.title || '黑马点评'
  const store = useSessionStore()
  if (to.name === 'profile' && !store.isLoggedIn) {
    return '/login'
  }
  return true
})

export default router
