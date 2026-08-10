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
    alias: '/shop-list',
    name: 'shops',
    component: () => import('@/views/ShopListView.vue'),
    meta: { title: '商户列表' }
  },
  {
    path: '/shop/:id',
    alias: '/shop-detail/:id',
    name: 'shop-detail',
    component: () => import('@/views/ShopDetailView.vue'),
    meta: { title: '商户详情' }
  },
  {
    path: '/blog/:id',
    alias: '/blog-detail/:id',
    name: 'blog-detail',
    component: () => import('@/views/BlogDetailView.vue'),
    meta: { title: '笔记详情' }
  },
  {
    path: '/blog-edit',
    name: 'blog-edit',
    component: () => import('@/views/BlogEditView.vue'),
    meta: { title: '发布笔记', requireAuth: true }
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
    meta: { title: '登录态', requireAuth: true }
  },
  {
    path: '/password-login',
    alias: '/login-password',
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
  if (to.meta.requireAuth && !store.isLoggedIn) {
    return '/login'
  }
  return true
})

export default router
