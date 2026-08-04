import request from '@/api/request'

export function getVoucherList(shopId) {
  return request.get(`/voucher/list/${shopId}`)
}

export function seckillVoucher(id) {
  return request.post(`/voucher-order/seckill/${id}`)
}
