<template>
  <div class="app-shell">
    <HeaderBar title="商户详情" />

    <div class="page compact">
      <div v-if="loading" class="list-status">正在加载商户详情...</div>
      <el-empty v-else-if="!shop" description="商户不存在" />
      <template v-else>
        <section class="detail-hero">
          <h1>{{ shop.name }}</h1>
          <div class="rating-line">
            <el-rate :model-value="score" disabled />
            <span>{{ shop.comments || 0 }}条评价</span>
          </div>
          <div class="shop-meta">
            <span>{{ shop.area || '杭州' }}</span>
            <span v-if="shop.avgPrice">￥{{ shop.avgPrice }}/人</span>
            <span v-if="shop.sold">已售 {{ shop.sold }}</span>
          </div>
        </section>

        <section v-if="images.length" class="image-grid">
          <img v-for="image in images.slice(0, 3)" :key="image" :src="image" :alt="shop.name" />
        </section>

        <section class="info-section">
          <div class="info-row">
            <el-icon><MapLocation /></el-icon>
            <span>{{ shop.address }}</span>
          </div>
          <div class="info-row">
            <el-icon><Clock /></el-icon>
            <span>营业时间：{{ shop.openHours || '以门店实际营业时间为准' }}</span>
          </div>
          <div class="info-row">
            <el-icon><Phone /></el-icon>
            <span>电话咨询请以前台信息为准</span>
          </div>
        </section>

        <section v-if="validVouchers.length" class="voucher-section">
          <div class="section-title">
            <strong>代金券</strong>
            <span>已对接 /voucher/list/{shopId}</span>
          </div>
          <div v-for="voucher in validVouchers" :key="voucher.id" class="voucher-card">
            <div class="voucher-left">
              <div class="voucher-title">{{ voucher.title }}</div>
              <div class="voucher-subtitle">{{ voucher.subTitle }}</div>
              <div class="voucher-price">
                <span class="price">￥{{ formatMoney(voucher.payValue) }}</span>
                <span class="voucher-ratio">{{ formatDiscount(voucher) }}折</span>
              </div>
            </div>
            <div class="voucher-right">
              <template v-if="voucher.type === 1">
                <el-button
                  type="primary"
                  :disabled="isSeckillNotBegin(voucher.beginTime) || isSeckillEnd(voucher.endTime) || voucher.stock < 1"
                  @click="handleSeckill(voucher)"
                >
                  {{ getSeckillText(voucher) }}
                </el-button>
                <div class="voucher-meta">
                  <span v-if="voucher.stock > 0">剩余 {{ voucher.stock }} 张</span>
                  <span v-else>已售罄</span>
                </div>
                <div class="voucher-meta">{{ formatSeckillTime(voucher.beginTime, voucher.endTime) }}</div>
              </template>
              <el-button v-else disabled>暂未开放</el-button>
            </div>
          </div>
        </section>
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Clock, MapLocation, Phone } from '@element-plus/icons-vue'
import HeaderBar from '@/components/HeaderBar.vue'
import { getShopById } from '@/api/shop'
import { getVoucherList, seckillVoucher } from '@/api/voucher'
import { useSessionStore } from '@/stores/session'

const route = useRoute()
const router = useRouter()
const session = useSessionStore()

const shop = ref(null)
const vouchers = ref([])
const loading = ref(false)

const images = computed(() => {
  const raw = shop.value?.images
  if (!raw) {
    return []
  }
  if (Array.isArray(raw)) {
    return raw.filter(Boolean)
  }
  return String(raw)
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean)
})

const score = computed(() => Number(shop.value?.score || 0) / 10)

const validVouchers = computed(() => {
  return vouchers.value.filter((voucher) => !isSeckillEnd(voucher.endTime))
})

function formatMoney(value) {
  const amount = Number(value || 0)
  return (amount / 100).toFixed(2)
}

function formatDiscount(voucher) {
  const pay = Number(voucher.payValue || 0)
  const actual = Number(voucher.actualValue || 0)
  if (!pay || !actual) {
    return '--'
  }
  return ((pay * 10) / actual).toFixed(1)
}

function formatSeckillTime(beginTime, endTime) {
  const begin = new Date(beginTime)
  const end = new Date(endTime)
  const pad = (val) => String(val).padStart(2, '0')
  return `${begin.getMonth() + 1}月${begin.getDate()}日 ${pad(begin.getHours())}:${pad(begin.getMinutes())} ~ ${pad(end.getHours())}:${pad(end.getMinutes())}`
}

function isSeckillNotBegin(beginTime) {
  return new Date(beginTime).getTime() > Date.now()
}

function isSeckillEnd(endTime) {
  return new Date(endTime).getTime() < Date.now()
}

function getSeckillText(voucher) {
  if (isSeckillNotBegin(voucher.beginTime)) return '即将开始'
  if (isSeckillEnd(voucher.endTime)) return '已结束'
  if (Number(voucher.stock || 0) < 1) return '已售罄'
  return '限时抢购'
}

async function loadShop() {
  shop.value = await getShopById(route.params.id)
}

async function loadVouchers() {
  vouchers.value = await getVoucherList(route.params.id)
}

async function handleSeckill(voucher) {
  if (!session.isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  if (isSeckillNotBegin(voucher.beginTime)) {
    ElMessage.warning('优惠券尚未开始')
    return
  }
  if (Number(voucher.stock || 0) < 1) {
    ElMessage.warning('库存不足')
    return
  }

  await seckillVoucher(voucher.id)
  ElMessage.success('抢购成功')
  await loadVouchers()
}

onMounted(async () => {
  loading.value = true
  try {
    await Promise.all([loadShop(), loadVouchers()])
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.voucher-section {
  margin-top: 14px;
  padding: 16px;
  border-radius: 8px;
  background: #fff;
  box-shadow: 0 10px 24px rgba(65, 39, 23, 0.06);
}

.voucher-card {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 12px;
  padding: 14px 0;
  border-top: 1px solid #f2e7df;
}

.voucher-card:first-of-type {
  border-top: none;
  padding-top: 0;
}

.voucher-title {
  font-size: 15px;
  font-weight: 700;
}

.voucher-subtitle,
.voucher-meta {
  margin-top: 4px;
  color: #8e847f;
  font-size: 12px;
}

.voucher-price {
  margin-top: 10px;
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.voucher-ratio {
  color: #d95519;
  font-size: 12px;
  font-weight: 700;
}

.voucher-right {
  display: grid;
  justify-items: end;
  gap: 8px;
  align-content: center;
}
</style>
