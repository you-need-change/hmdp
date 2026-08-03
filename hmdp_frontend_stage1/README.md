# hmdp_frontend_stage1

一套独立于现有 `hmdp_frontend` 的阶段前端，只对接当前已经实现的后端能力：

- `POST /user/code`
- `POST /user/login`
- `GET /user/me`
- `GET /user/info/{id}`
- `POST /user/logout`
- `GET /shop-type/list`
- `GET /shop/of/type`
- `GET /shop/of/name`
- `GET /shop/{id}`

当前页面：

- 首页：分类、搜索、登录入口
- 验证码登录页：可直接走登录链路
- 登录态页：展示 `/user/me` 返回的真实用户信息和 `/user/info/{id}` 资料详情
- 商户列表页：按类型查询商户
- 商户详情页：展示商户基础信息
- 密码登录页：仅说明后端尚未实现

开发：

```bash
npm install
npm run dev
```

默认前端端口：`3001`

默认代理后端：`http://localhost:8081`
