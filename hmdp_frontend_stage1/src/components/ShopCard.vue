<template>
  <button class="shop-card" type="button" @click="router.push(`/shop/${shop.id}`)">
    <div class="shop-cover">
      <img :src="cover" :alt="shop.name" />
    </div>
    <div class="shop-info">
      <div class="row-between">
        <h3>{{ shop.name }}</h3>
        <span v-if="shop.avgPrice" class="price">￥{{ shop.avgPrice }}/人</span>
      </div>
      <div class="rating-line">
        <el-rate :model-value="score" disabled size="small" />
        <span>{{ shop.comments || 0 }}条评价</span>
      </div>
      <div class="shop-meta">
        <span>{{ shop.area || '杭州' }}</span>
        <span v-if="distanceText">{{ distanceText }}</span>
        <span v-if="shop.sold">已售 {{ shop.sold }}</span>
      </div>
      <div class="address">
        <el-icon><MapLocation /></el-icon>
        <span>{{ shop.address }}</span>
      </div>
    </div>
  </button>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { MapLocation } from '@element-plus/icons-vue'
import { formatDistance } from '@/utils/format'

const props = defineProps({
  shop: {
    type: Object,
    required: true
  }
})

const router = useRouter()

const cover = computed(() => {
  const images = props.shop.images || ''
  return images.split(',').filter(Boolean)[0] || '/imgs/types/ms.png'
})

const score = computed(() => Number(props.shop.score || 0) / 10)

const distanceText = computed(() => formatDistance(props.shop.distance))
</script>
