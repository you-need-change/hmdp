# hmdp_frontend_stage1

一套独立于现有 `hmdp_frontend` 的阶段前端，只对接当前已经实现的后端能力。

## 已对接接口

用户：

- `POST /user/code` 发送验证码
- `POST /user/login` 验证码登录
- `GET /user/me` 当前登录用户
- `GET /user/info/{id}` 资料详情
- `POST /user/logout` 退出登录

商户：

- `GET /shop-type/list` 商户分类
- `GET /shop/of/type` 按分类查询商户
- `GET /shop/of/name` 按名称搜索商户
- `GET /shop/{id}` 商户详情

优惠券与秒杀：

- `GET /voucher/list/{shopId}` 商户代金券列表
- `POST /voucher-order/seckill/{id}` 秒杀抢购

笔记：

- `GET /blog/hot` 热门笔记（分页）
- `GET /blog/{id}` 笔记详情
- `GET /blog/of/me` 我的笔记
- `GET /blog/of/follow` 关注流
- `PUT /blog/like/{id}` 点赞/取消点赞
- `GET /blog/likes/{id}` 点赞用户列表
- `POST /blog` 发布笔记

关注：

- `GET /follow/or/not/{id}` 判断是否已关注
- `PUT /follow/{id}/{isFollow}` 关注/取消关注
- `GET /follow/common/{id}` 共同关注

上传：

- `POST /upload/blog` 上传笔记图片
- `GET /upload/blog/delete` 删除笔记图片

> `POST /shop`、`PUT /shop`、`POST /voucher`、`POST /voucher/seckill` 属于管理端能力，前端暂不做页面。

## 当前页面

- 首页：分类、搜索、热门笔记、登录入口
- 验证码登录页：可直接走登录链路
- 登录态页：展示 `/user/me` 用户信息、`/user/info/{id}` 资料详情和 `/blog/of/me` 我的笔记
- 商户列表页：按类型查询商户
- 商户详情页：展示商户基础信息和代金券秒杀
- 密码登录页：仅说明后端尚未实现
- 笔记详情页：图片轮播、作者信息、关注、点赞用户、关联商户
- 发布笔记页：标题、内容、上传图片、关联商户（需登录）

开发：

```bash
npm install
npm run dev
```

默认前端端口：`3001`

默认代理后端：`http://localhost:8081`
