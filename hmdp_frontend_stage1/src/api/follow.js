import request from '@/api/request'

export function isFollowed(id) {
  return request.get(`/follow/or/not/${id}`)
}

export function followUser(id, isFollow) {
  return request.put(`/follow/${id}/${isFollow}`)
}

export function getCommonFollows(id) {
  return request.get(`/follow/common/${id}`)
}
