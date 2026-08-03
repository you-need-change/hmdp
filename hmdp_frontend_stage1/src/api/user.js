import request from '@/api/request'

export function sendCode(phone) {
  return request.post(`/user/code?phone=${phone}`)
}

export function loginByCode(data) {
  return request.post('/user/login', data)
}

export function getMe() {
  return request.get('/user/me')
}

export function getUserDetail(id) {
  return request.get(`/user/info/${id}`)
}

export function logout() {
  return request.post('/user/logout')
}
