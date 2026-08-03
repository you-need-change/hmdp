import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useSessionStore } from '@/stores/session'

const request = axios.create({
  baseURL: '/api',
  timeout: 10000
})

request.interceptors.request.use((config) => {
  const store = useSessionStore()
  if (store.token) {
    config.headers.authorization = store.token
  }
  return config
})

request.interceptors.response.use(
  (response) => {
    const payload = response.data
    if (!payload.success) {
      const message = payload.errorMsg || '请求失败'
      ElMessage.error(message)
      return Promise.reject(new Error(message))
    }
    return payload.data
  },
  (error) => {
    const message = error.response?.data?.errorMsg || error.message || '服务异常'
    ElMessage.error(message)
    return Promise.reject(error)
  }
)

export default request
