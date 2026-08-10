import request from '@/api/request'

// 热门笔记列表（分页，后端每页最多 10 条）
export function getHotBlogs(current = 1) {
  return request.get('/blog/hot', { params: { current } })
}

// 笔记详情
export function getBlogById(id) {
  return request.get(`/blog/${id}`)
}

// 当前登录用户的笔记列表
export function getMyBlogs(current = 1) {
  return request.get('/blog/of/me', { params: { current } })
}

// 关注用户的笔记流（滚动分页）
export function getFollowBlogs(params) {
  return request.get('/blog/of/follow', { params })
}

// 点赞/取消点赞，返回 true 表示已点赞，false 表示取消
export function likeBlog(id) {
  return request.put(`/blog/like/${id}`)
}

// 笔记前 5 个点赞用户
export function getBlogLikes(id) {
  return request.get(`/blog/likes/${id}`)
}

// 发布笔记
export function publishBlog(data) {
  return request.post('/blog', data)
}
