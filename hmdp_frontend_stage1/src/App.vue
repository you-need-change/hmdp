<template>
  <router-view />
</template>

<script setup>
import { onMounted } from 'vue';
import axios from 'axios'

onMounted( async () => {
// try {
//   const resp = await axios.post('http://localhost:8081/user/login',
//     {
//       phone: "18914687904",
//       code: "044287",
//       password: ""
//     }
//   )

//   if (resp.data.success) {
//     console.log(resp.data.data)
//   } else {
//     console.log("请求失败！")
//   }
// } catch (error) {
//   console.log(error)
// }

// try {
//   const resp = await axios.get('http://localhost:8081/shop/1',
//     {
//       headers:{
//         "Content-Type": "application/json",
//         "authorization": "758a4596-1e99-45b5-afa1-5c35c16ea1a5"
//       }
//     }
//   )

//   if (resp.data.success) {
//     console.log(resp.data.data)
//   } else {
//     console.log("请求失败！")
//   }
// } catch (error) {
//   console.log(error)
// }

  // try {
  //   const resp = await axios.get('http://localhost:8081/blog/4')

  //   if (resp.data.success) {
  //     console.log(resp.data.data)
  //   } else {
  //     console.log("请求失败！")
  //   }
  // } catch (error) {
  //   console.log(error)
  // }

  // try {
  //   const resp = await axios.get('http://localhost:8081/blog/hot')

  //   if (resp.data.success) {
  //     console.log(resp.data.data)
  //   } else {
  //     console.log("请求失败！")
  //   }
  // } catch (error) {
  //   console.log(error)
  // }

      // try {
  //   const resp = await axios.get('http://localhost:8081/blog/4')

  //   if (resp.data.success) {
  //     console.log(resp.data.data)
  //   } else {
  //     console.log("请求失败！")
  //   }
  // } catch (error) {
  //   console.log(error)
  // }

  // try {
  //   const resp = await axios.get('http://localhost:8081/blog/of/follow',
  //     {
  //       params:{
  //         "lastId": 999999999999999999,
  //         "offset": 0,
  //       },
  //       headers:{
  //         "Content-Type": "application/json",
  //         "authorization": "8767e65e-46be-4e45-957c-f3ef41aedf63"
  //       }
  //     }
  //   )

  //   if (resp.data.success) {
  //     console.log(resp.data.data)
  //   } else {
  //     console.log("请求失败！")
  //   }
  // } catch (error) {
  //   console.log(error)
  // }

}
)
</script>