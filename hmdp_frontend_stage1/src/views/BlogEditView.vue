<template>
  <div class="app-shell">
    <HeaderBar title="发布笔记">
      <template #right>
        <el-button type="primary" size="small" :loading="publishing" @click="publish">
          发布
        </el-button>
      </template>
    </HeaderBar>

    <div class="page compact">
      <section class="edit-card">
        <div class="section-title">
          <strong>图片</strong>
          <span>已对接 /upload/blog</span>
        </div>
        <div class="image-row">
          <button class="image-add" type="button" @click="fileInput?.click()">
            <el-icon :size="22"><Camera /></el-icon>
            <span>上传照片</span>
          </button>
          <input
            ref="fileInput"
            type="file"
            accept="image/*"
            multiple
            style="display: none"
            @change="handleFiles"
          />
          <div v-for="(image, index) in images" :key="image.url" class="image-item">
            <img :src="image.url" alt="" />
            <button class="image-remove" type="button" @click="removeImage(index)">
              <el-icon><Close /></el-icon>
            </button>
          </div>
          <button class="image-add small" type="button" @click="addDemoImage">
            <span>+ 演示图</span>
          </button>
        </div>
        <div class="url-row">
          <el-input
            v-model="imageUrl"
            size="small"
            placeholder="或粘贴图片 URL 后回车添加"
            clearable
            @keyup.enter="addImageUrl"
          />
          <el-button size="small" @click="addImageUrl">添加</el-button>
        </div>
      </section>

      <section class="edit-card">
        <el-input v-model="form.title" maxlength="64" show-word-limit placeholder="填写标题更容易上首页哦~" />
        <el-input
          v-model="form.content"
          type="textarea"
          :rows="6"
          resize="none"
          placeholder="最近打卡了什么地方，有什么新奇体验呢？"
        />
      </section>

      <section class="edit-card">
        <button class="shop-row" type="button" @click="showShopDialog = true">
          <span class="label">关联商户</span>
          <span class="value" :class="{ placeholder: !selectedShop }">
            {{ selectedShop?.name || '去选择' }}
          </span>
          <el-icon><ArrowRight /></el-icon>
        </button>
      </section>
    </div>

    <div v-if="showShopDialog" class="dialog-mask" @click="showShopDialog = false"></div>
    <transition name="slide-up">
      <div v-if="showShopDialog" class="shop-dialog">
        <div class="dialog-header">
          <strong>关联商户</strong>
          <button class="icon-btn" type="button" @click="showShopDialog = false">
            <el-icon><Close /></el-icon>
          </button>
        </div>
        <div class="dialog-search">
          <el-input
            v-model="shopKeyword"
            size="small"
            placeholder="搜索商户名称"
            clearable
            @keyup.enter="searchShop"
          />
          <el-button size="small" type="primary" @click="searchShop">搜索</el-button>
        </div>
        <div class="dialog-list">
          <div v-if="!searching && !shopResults.length" class="list-status">输入名称搜索商户</div>
          <button
            v-for="shop in shopResults"
            :key="shop.id"
            class="shop-option"
            type="button"
            @click="selectShop(shop)"
          >
            <strong>{{ shop.name }}</strong>
            <span>{{ shop.area }}</span>
          </button>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowRight, Camera, Close } from '@element-plus/icons-vue'
import HeaderBar from '@/components/HeaderBar.vue'
import { publishBlog } from '@/api/blog'
import { searchShops } from '@/api/shop'
import { deleteBlogImage, uploadBlogImage } from '@/api/upload'

const router = useRouter()

const fileInput = ref(null)
const images = ref([])
const imageUrl = ref('')
const form = reactive({
  title: '',
  content: ''
})
const selectedShop = ref(null)
const showShopDialog = ref(false)
const shopKeyword = ref('')
const shopResults = ref([])
const searching = ref(false)
const publishing = ref(false)

function addImageUrl() {
  const url = imageUrl.value.trim()
  if (!url) {
    return
  }
  images.value.push({
    url,
    name: null,
    remote: false
  })
  imageUrl.value = ''
}

function addDemoImage() {
  if (!images.value.some((image) => image.url === '/imgs/blogs/blog1.jpg')) {
    images.value.push({
      url: '/imgs/blogs/blog1.jpg',
      name: null,
      remote: false
    })
  }
}

async function handleFiles(event) {
  const files = Array.from(event.target.files || [])
  const available = Math.max(0, 9 - images.value.length)
  for (const file of files.slice(0, available)) {
    try {
      const name = await uploadBlogImage(file)
      images.value.push({
        url: `/imgs${name}`,
        name,
        remote: true
      })
    } catch (error) {
      // 拦截器已提示错误
    }
  }
  event.target.value = ''
}

async function removeImage(index) {
  const image = images.value[index]
  if (!image) {
    return
  }
  if (image.remote && image.name) {
    try {
      await deleteBlogImage(image.name)
    } catch (error) {
      return
    }
  }
  images.value.splice(index, 1)
}

async function searchShop() {
  const name = shopKeyword.value.trim()
  if (!name) {
    ElMessage.warning('请输入商户名称')
    return
  }
  searching.value = true
  try {
    shopResults.value = await searchShops(name)
  } finally {
    searching.value = false
  }
}

function selectShop(shop) {
  selectedShop.value = shop
  showShopDialog.value = false
}

async function publish() {
  if (!form.title.trim() && !form.content.trim()) {
    ElMessage.warning('请填写标题或内容')
    return
  }

  publishing.value = true
  try {
    const id = await publishBlog({
      title: form.title.trim(),
      content: form.content.trim(),
      images: images.value.map((image) => image.url).join(','),
      shopId: selectedShop.value?.id
    })
    ElMessage.success('发布成功')
    router.push(`/blog/${id}`)
  } catch (error) {
    // 错误已由拦截器提示
  } finally {
    publishing.value = false
  }
}
</script>

<style scoped>
.edit-card {
  padding: 16px;
  border-radius: 8px;
  background: #fff;
  box-shadow: 0 10px 24px rgba(65, 39, 23, 0.06);
}

.edit-card + .edit-card {
  margin-top: 14px;
}

.image-row {
  display: flex;
  gap: 10px;
  overflow-x: auto;
  padding-bottom: 4px;
}

.image-add {
  width: 84px;
  height: 84px;
  flex-shrink: 0;
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  border: 1px dashed #e2cdbd;
  border-radius: 8px;
  background: #fffaf6;
  color: #8e847f;
  font-size: 12px;
  cursor: pointer;
}

.image-add.small {
  font-size: 13px;
  font-weight: 700;
}

.image-item {
  position: relative;
  width: 84px;
  height: 84px;
  flex-shrink: 0;
  border-radius: 8px;
  overflow: hidden;
  background: #fff2e9;
}

.image-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-remove {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 20px;
  height: 20px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.5);
  color: #fff;
  cursor: pointer;
}

.url-row {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 8px;
  margin-top: 12px;
}

.shop-row {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 12px;
  border: none;
  background: transparent;
  color: #4d4038;
  font-size: 14px;
  cursor: pointer;
}

.shop-row .value {
  flex: 1;
  text-align: right;
}

.shop-row .value.placeholder {
  color: #8e847f;
}

.dialog-mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  z-index: 20;
}

.shop-dialog {
  position: fixed;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 100%;
  max-width: 540px;
  height: 68vh;
  display: flex;
  flex-direction: column;
  padding: 16px;
  border-radius: 16px 16px 0 0;
  background: #fff;
  z-index: 21;
}

.dialog-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.dialog-search {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 8px;
}

.dialog-list {
  flex: 1;
  overflow-y: auto;
  margin-top: 12px;
}

.shop-option {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 14px 4px;
  border: none;
  border-bottom: 1px solid #f2e7df;
  background: transparent;
  color: #4d4038;
  cursor: pointer;
}

.shop-option span {
  color: #8e847f;
  font-size: 12px;
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: transform 0.25s ease;
}

.slide-up-enter-from,
.slide-up-leave-to {
  transform: translate(-50%, 100%);
}
</style>
