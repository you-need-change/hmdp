<template>
  <router-view />
</template>

<script setup>
import { onMounted } from 'vue';
import axios from 'axios'

onMounted(async () => {
  // try {
  //   const resp = await axios.post('http://localhost:8081/user/login', {
  //     phone: "15912345678",
  //     code: "857940",
  //     password: null
  //   })
  //   if (resp.data.success === true) {
  //     console.log(resp.data.data)
  //   } else {
  //     console.log(resp.data.errorMsg)
  //   }
  // } catch (error) {
  //   console.log(error)
  // }

  try {
    const resp = await axios.post('http://localhost:8081/voucher-order/seckill/2', 
    null, 
  //   {
  //     "shopId": "1",
  //     "title": "100元代金券",
  //     "subTitle": "周一到周五均可使用",
  //     "rules": "全场通用",
  //     "payValue": "8000",
  //     "actualValue": "10000",
  //     "type": "1",
  //     "stock": "100",
  //     "beginTime": "2026-01-01T00:00:00",
  //     "endTime": "2026-12-31T23:59:59"
  // },
    {
      headers: {
        'Content-Type': 'application/json',
        'authorization': "6e820e18-e843-497b-a686-fd2469295d31"
      },
    })
    if (resp.data.success === true) {
      console.log(resp.data.data)
    } else {
      console.log(resp.data.errorMsg)
    }
  } catch (error) {
    console.log(error)
  }
})
</script>