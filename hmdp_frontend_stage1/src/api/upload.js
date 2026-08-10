import request from '@/api/request'

export function uploadBlogImage(file) {
  const formData = new FormData()
  formData.append('file', file)

  return request.post('/upload/blog', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
}

export function deleteBlogImage(name) {
  return request.get('/upload/blog/delete', { params: { name } })
}
