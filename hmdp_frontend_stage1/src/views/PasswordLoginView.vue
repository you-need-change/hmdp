<template>
  <div class="app-shell">
    <div class="page">
      <div class="topbar">
        <button class="ghost-btn" @click="router.push('/login')">返回</button>
        <div class="topbar-title">密码登录</div>
        <span></span>
      </div>

      <div class="card">
        <p class="eyebrow">NOT IMPLEMENTED</p>
        <h2 style="margin: 0 0 12px;">当前后端还没做密码登录</h2>
        <p class="muted">
          现在后端只有验证码发送和验证码登录，所以这页只保留说明，不接假的密码表单。
        </p>
        <el-button type="primary" style="margin-top: 16px;" @click="router.push('/login')">
          返回验证码登录
        </el-button>
      </div>
    </div>

    <BottomNav current="login" />
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import BottomNav from '@/components/BottomNav.vue'

const router = useRouter()
</script>
