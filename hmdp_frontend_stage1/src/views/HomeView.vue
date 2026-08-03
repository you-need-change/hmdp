<template>
  <div class="app-shell">
    <div class="home-top">
      <div class="city-select">
        杭州 <el-icon><ArrowDown /></el-icon>
      </div>
      <el-input
        v-model="keyword"
        clearable
        placeholder="搜索商户名"
        :prefix-icon="Search"
        @keyup.enter="handleSearch"
      />
      <button class="icon-btn profile-shortcut" type="button" @click="goProfile">
        <el-icon><User /></el-icon>
      </button>
    </div>

    <div class="page">
      <section class="category-panel">
        <div class="section-title">
          <strong>分类</strong>
          <span>已对接 /shop-type/list</span>
        </div>
        <div v-if="loadingTypes" class="list-status">正在加载分类...</div>
        <div v-else class="type-grid">
          <button v-for="type in shopTypes" :key="type.id" class="type-item" type="button" @click="toShops(type)">
            <img :src="`/imgs${type.icon}`" :alt="type.name" />
            <span>{{ type.name }}</span>
          </button>
        </div>
      </section>

      <section class="category-panel">
        <div class="section-title">
          <strong>商户搜索</strong>
          <span>已对接 /shop/of/name</span>
        </div>
        <div v-if="searching" class="list-status">正在搜索...</div>
        <el-empty v-else-if="searched && !searchResults.length" description="没有找到商户" />
        <div v-else-if="searchResults.length" class="shop-list">
          <ShopCard v-for="shop in searchResults" :key="shop.id" :shop="shop" />
        </div>
        <p v-else class="muted">
          输入商户名后回车搜索，也可以直接从分类进入列表。
        </p>
      </section>

      <section class="session-band">
        <div>
          <strong>{{ store.isLoggedIn ? store.displayName : '未登录' }}</strong>
          <span>{{ store.isLoggedIn ? store.maskedPhone : '登录后可查看 /user/me 信息' }}</span>
        </div>
        <el-button size="small" :type="store.isLoggedIn ? 'primary' : 'default'" @click="goProfile">
          {{ store.isLoggedIn ? '我的' : '登录' }}
        </el-button>
      </section>
    </div>

    <BottomNav current="home" />
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowDown, Search, User } from '@element-plus/icons-vue'
import BottomNav from '@/components/BottomNav.vue'
import ShopCard from '@/components/ShopCard.vue'
import { useSessionStore } from '@/stores/session'
import { getShopTypes, searchShops } from '@/api/shop'

const router = useRouter()
const store = useSessionStore()

const keyword = ref('')
const shopTypes = ref([])
const loadingTypes = ref(false)
const searching = ref(false)
const searched = ref(false)
const searchResults = ref([])

function toShops(type) {
  router.push({
    path: '/shops',
    query: {
      typeId: type.id,
      typeName: type.name
    }
  })
}

function goProfile() {
  router.push(store.isLoggedIn ? '/profile' : '/login')
}

async function handleSearch() {
  const name = keyword.value.trim()
  if (!name) {
    ElMessage.warning('请输入商户名称')
    return
  }
  searching.value = true
  searched.value = true
  try {
    searchResults.value = await searchShops(name)
  } finally {
    searching.value = false
  }
}

onMounted(async () => {
  loadingTypes.value = true
  try {
    shopTypes.value = await getShopTypes()
  } finally {
    loadingTypes.value = false
  }
})
</script>
