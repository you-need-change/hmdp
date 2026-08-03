import request from '@/api/request'

export function getShopTypes() {
  return request.get('/shop-type/list')
}

export function getShopList(params) {
  return request.get('/shop/of/type', { params })
}

export function searchShops(name, current = 1) {
  return request.get('/shop/of/name', {
    params: {
      name,
      current
    }
  })
}

export function getShopById(id) {
  return request.get(`/shop/${id}`)
}
