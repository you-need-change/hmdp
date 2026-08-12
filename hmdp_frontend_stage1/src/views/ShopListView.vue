<template>
  <div class="app-shell">
    <HeaderBar :title="title">
      <template #right>
        <button class="icon-btn" type="button" @click="showSearch = !showSearch">
          <el-icon><Search /></el-icon>
        </button>
      </template>
    </HeaderBar>

    <div class="page compact">
      <div v-if="showSearch" class="search-panel">
        <el-input
          v-model="keyword"
          clearable
          placeholder="搜索商户名称"
          :prefix-icon="Search"
          @keyup.enter="handleSearch"
        />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>

      <div class="filter-strip">
        <el-dropdown trigger="click" @command="changeType">
          <button class="filter-btn" type="button">
            {{ typeName }} <el-icon><ArrowDown /></el-icon>
          </button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item v-for="type in shopTypes" :key="type.id" :command="type">
                {{ type.name }}
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
        <button
          class="filter-btn"
          :class="{ active: sortMode === 'default' }"
          type="button"
          @click="useDefaultSort"
        >
          综合排序
        </button>
        <button
          class="filter-btn"
          :class="{ active: sortMode === 'distance' }"
          type="button"
          @click="useDistanceSort"
        >
          距离优先
        </button>
      </div>

      <div class="list-status" v-if="loading">正在加载商户...</div>
      <el-empty v-else-if="!shops.length" description="暂无商户数据" />
      <div v-else class="shop-list">
        <ShopCard v-for="shop in shops" :key="shop.id" :shop="shop" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowDown, Search } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import HeaderBar from '@/components/HeaderBar.vue'
import ShopCard from '@/components/ShopCard.vue'
import { getShopList, getShopTypes, searchShops } from '@/api/shop'

const DEFAULT_LOCATION = {
  x: 120.149993,
  y: 30.334229
}

const route = useRoute()
const router = useRouter()

const shopTypes = ref([])
const shops = ref([])
const loading = ref(false)
const typeId = ref(Number(route.query.typeId || 1))
const typeName = ref(route.query.typeName || '商户')
const keyword = ref('')
const showSearch = ref(false)
const sortMode = ref('default')
const location = ref({ ...DEFAULT_LOCATION })

const title = computed(() => (keyword.value ? '搜索结果' : typeName.value))

function getBrowserLocation() {
  return new Promise((resolve) => {
    if (!navigator.geolocation) {
      resolve({ ...DEFAULT_LOCATION })
      return
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve({
          x: position.coords.longitude,
          y: position.coords.latitude
        })
      },
      () => {
        resolve({ ...DEFAULT_LOCATION })
      },
      {
        enableHighAccuracy: true,
        timeout: 3000,
        maximumAge: 300000
      }
    )
  })
}

async function fetchTypes() {
  shopTypes.value = await getShopTypes()
  if (!route.query.typeName) {
    const selected = shopTypes.value.find((type) => type.id === typeId.value)
    typeName.value = selected?.name || shopTypes.value[0]?.name || '商户'
    typeId.value = selected?.id || shopTypes.value[0]?.id || typeId.value
  }
}

async function reload() {
  loading.value = true
  try {
    const params = {
      typeId: typeId.value,
      current: 1
    }
    if (sortMode.value === 'distance') {
      params.x = location.value.x
      params.y = location.value.y
    }
    shops.value = await getShopList(params)
  } finally {
    loading.value = false
  }
}

async function useDefaultSort() {
  sortMode.value = 'default'
  await reload()
}

async function useDistanceSort() {
  if (sortMode.value !== 'distance') {
    location.value = await getBrowserLocation()
  }
  sortMode.value = 'distance'
  await reload()
}

async function changeType(type) {
  typeId.value = type.id
  typeName.value = type.name
  keyword.value = ''
  showSearch.value = false
  router.replace({
    path: '/shops',
    query: {
      typeId: type.id,
      typeName: type.name
    }
  })
  await reload()
}

async function handleSearch() {
  const name = keyword.value.trim()
  if (!name) {
    ElMessage.warning('请输入商户名称')
    return
  }
  loading.value = true
  try {
    shops.value = await searchShops(name)
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await fetchTypes()
  location.value = await getBrowserLocation()
  await reload()
})
</script>
