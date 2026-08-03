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
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { Clock, MapLocation, Phone } from '@element-plus/icons-vue'
import HeaderBar from '@/components/HeaderBar.vue'
import { getShopById } from '@/api/shop'

const route = useRoute()
const shop = ref(null)
const loading = ref(false)

const images = computed(() => {
  return (shop.value?.images || '').split(',').filter(Boolean)
})

const score = computed(() => Number(shop.value?.score || 0) / 10)

onMounted(async () => {
  loading.value = true
  try {
    shop.value = await getShopById(route.params.id)
  } finally {
    loading.value = false
  }
})
</script>
