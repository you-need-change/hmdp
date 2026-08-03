<template>
  <div class="header-bar">
    <button v-if="showBack" class="icon-btn" type="button" @click="router.back()">
      <el-icon><ArrowLeft /></el-icon>
    </button>
    <span v-else class="icon-spacer"></span>
    <div class="header-title">{{ title }}</div>
    <div class="header-right">
      <slot name="right"></slot>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'

defineProps({
  title: {
    type: String,
    default: ''
  },
  showBack: {
    type: Boolean,
    default: true
  }
})

const router = useRouter()
</script>
