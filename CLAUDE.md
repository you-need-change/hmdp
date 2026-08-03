# 黑马点评项目 - 教学开发指南

## 项目概述

这是一个基于 Spring Boot 的本地生活点评项目，类似大众点评，包含用户登录、商铺查询、优惠券秒杀、博客发布、关注功能等核心业务模块。

**核心技术栈：**
- Spring Boot 2.7.4
- Spring Data Redis（缓存方案）
- MyBatis-Plus 3.5.2（持久层框架）
- MySQL（关系型数据库）
- Hutool 5.8.8（Java 工具库）
- Lombok（简化实体类）

## 教学开发原则

### ⚠️ 渐进式开发策略

本项目采用**教学导向的渐进式开发模式**，遵循以下核心原则：

1. **按需创建文件** - 不要一次性生成所有代码文件，只在需要实现某个功能时才创建对应的类
2. **功能模块化推进** - 每次只关注一个业务模块的完整实现流程
3. **理解开发流程** - 重点是熟悉从 Controller → Service → Mapper → Entity 的完整开发链路
4. **逐步完善功能** - 先实现核心功能，再根据需求添加扩展功能
5. **参考源码开发** - 参考 `.\sourcecode\` 目录中的完整实现代码，学习其设计思路和最佳实践

### 开发顺序建议

按照以下顺序逐步实现功能模块：

```
阶段 1: 基础环境搭建
└── 配置文件、启动类、通用配置

阶段 2: 用户模块（最基础）
├── 短信验证码登录
├── Session 共享问题
└── Redis 替代 Session

阶段 3: 商铺模块（缓存核心）
├── 商铺查询与缓存
├── 缓存更新策略
├── 缓存穿透、击穿、雪崩问题
└── 全局 ID 生成器

阶段 4: 优惠券秒杀（分布式锁）
├── 秒杀业务实现
├── 超卖问题解决
├── 分布式锁实现
└── Redis 实现秒杀

阶段 5: 博客与关注（Feed 流）
├── 点赞功能（Set 结构）
├── 关注功能（Set 实现共同关注）
└── Feed 流推送（SortedSet 实现滚动分页）

阶段 6: 附近商铺（GEO）
└── Redis GEO 数据结构实现附近商铺搜索
```

## 核心业务模块

### 1. 用户模块（com.hmdp.controller.UserController）
**核心功能：**
- 短信验证码发送与验证
- 用户登录/注册
- 用户信息查询

**涉及文件：**
- `UserController.java` - 用户请求处理
- `UserServiceImpl.java` - 业务逻辑
- `UserMapper.java` - 数据访问
- `User.java` / `UserDTO.java` - 实体类

**技术要点：**
- Redis 存储验证码（带过期时间）
- Session 共享问题及解决方案
- 登录拦截器实现

---

### 2. 商铺模块（com.hmdp.controller.ShopController）
**核心功能：**
- 商铺信息查询
- 商铺类型查询
- 缓存策略实现

**涉及文件：**
- `ShopController.java` / `ShopTypeController.java`
- `ShopServiceImpl.java`
- `Shop.java` / `ShopType.java`

**技术要点：**
- Redis 缓存商铺信息
- 缓存穿透解决方案（缓存空对象、布隆过滤器）
- 缓存击穿解决方案（互斥锁、逻辑过期）
- 缓存更新策略（双写一致性）

---

### 3. 优惠券秒杀模块（com.hmdp.controller.VoucherOrderController）
**核心功能：**
- 秒杀优惠券下单
- 库存扣减
- 一人一单限制

**涉及文件：**
- `VoucherController.java` / `VoucherOrderController.java`
- `VoucherOrderServiceImpl.java`
- `SeckillVoucher.java` / `VoucherOrder.java`

**技术要点：**
- 超卖问题解决（乐观锁）
- 分布式锁实现（Redis SETNX）
- Redisson 分布式锁框架
- 异步秒杀优化（Redis + Lua 脚本）

---

### 4. 博客模块（com.hmdp.controller.BlogController）
**核心功能：**
- 发布探店笔记
- 点赞功能
- 查询热门笔记

**涉及文件：**
- `BlogController.java`
- `BlogServiceImpl.java`
- `Blog.java`

**技术要点：**
- Redis Set 实现点赞功能
- SortedSet 实现点赞排行榜
- Feed 流推送模式（Timeline、智能推荐）

---

### 5. 关注模块（com.hmdp.controller.FollowController）
**核心功能：**
- 关注/取关用户
- 查询共同关注
- 关注用户的 Feed 流

**技术要点：**
- Redis Set 实现关注列表
- Set 交集实现共同关注
- SortedSet 实现滚动分页

---

## 开发工作流示例

### 示例：实现用户登录功能

**步骤 1：创建 Controller 层**
```java
// UserController.java - 处理登录请求
@PostMapping("/login")
public Result login(@RequestBody LoginFormDTO loginForm) {
    // 调用 service 层
}
```

**步骤 2：创建 Service 层**
```java
// UserServiceImpl.java - 实现登录业务逻辑
public Result login(LoginFormDTO loginForm) {
    // 1. 校验手机号和验证码
    // 2. 查询用户信息
    // 3. 保存用户信息到 Redis
    // 4. 返回 token
}
```

**步骤 3：创建 Mapper 层（如需要）**
```java
// UserMapper.java - 数据库查询
User selectByPhone(String phone);
```

**步骤 4：测试验证**
- 使用 Postman 或前端页面测试接口
- 验证 Redis 中的数据存储
- 检查异常情况处理

---

## 重要配置文件

### application.yml（需要配置）
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/hmdp?useSSL=false&serverTimezone=UTC
    username: root
    password: your_password
  
  redis:
    host: 127.0.0.1
    port: 6379
    lettuce:
      pool:
        max-active: 10
        max-idle: 10
        min-idle: 1
        time-between-eviction-runs: 10s

mybatis-plus:
  type-aliases-package: com.hmdp.entity
```

---

## 开发时的 AI 协作指令

在使用 Claude 辅助开发时，请遵循以下指令：

1. **不要一次性生成所有文件** - 每次只生成当前需要的类和方法
2. **先讲解后实现** - 在编写代码前，先解释该功能的实现思路和技术要点
3. **分步骤实现** - 将复杂功能拆分成多个小步骤，逐步完成
4. **及时测试验证** - 完成一个功能点后，立即测试验证效果
5. **保留注释说明** - 关键业务逻辑和技术难点需要添加注释
6. **参考源码实现** - 在开发功能时，必须参考 `.\sourcecode\` 目录中对应的代码实现，确保代码质量和最佳实践

### 正确的协作方式示例

❌ **错误方式：** "帮我实现用户登录、商铺查询、秒杀等所有功能"
✅ **正确方式：** "先实现用户短信登录功能，包括验证码发送和登录接口"

❌ **错误方式：** "直接生成 UserServiceImpl 完整代码"
✅ **正确方式：** "先讲解登录流程需要哪些步骤，然后逐步实现验证码校验、用户查询、Redis 存储等功能"

---

## 常见问题与解决方案

### Q1: 为什么使用 Redis 替代 Session？
- Session 基于 Tomcat 内存，集群环境下无法共享
- Redis 支持分布式共享，多个服务器可以访问同一份数据

### Q2: 缓存穿透、击穿、雪崩的区别？
- **穿透**：查询不存在的数据，导致每次都查数据库
- **击穿**：热点 key 过期瞬间，大量请求打到数据库
- **雪崩**：大量 key 同时过期，数据库压力激增

### Q3: 为什么秒杀需要分布式锁？
- 单机锁无法在集群环境下保证线程安全
- 需要 Redis 分布式锁确保"一人一单"业务逻辑

---

## 数据库说明

数据库脚本位于：`hmdp.sql`

**核心表结构：**
- `tb_user` - 用户表
- `tb_user_info` - 用户详情表
- `tb_shop` - 商铺表
- `tb_shop_type` - 商铺类型表
- `tb_blog` - 博客表
- `tb_voucher` - 优惠券表
- `tb_seckill_voucher` - 秒杀优惠券表
- `tb_voucher_order` - 优惠券订单表
- `tb_follow` - 关注表

---

## 项目启动流程

1. 导入 `hmdp.sql` 到 MySQL 数据库
2. 启动 Redis 服务
3. 修改 `application.yml` 中的数据库和 Redis 配置
4. 运行 `HmDianPingApplication.java` 启动项目
5. 访问前端页面或使用 Postman 测试接口

---

## 学习目标

通过本项目的渐进式开发，你将掌握：

✅ Spring Boot 项目的标准开发流程  
✅ Redis 在实际项目中的应用（缓存、分布式锁、数据结构）  
✅ 高并发场景下的常见问题及解决方案  
✅ 分布式系统的核心技术（Session 共享、分布式锁、Feed 流）  
✅ MyBatis-Plus 的基本使用  
✅ RESTful API 的设计规范  

**记住：不要急于求成，每次只专注一个功能模块的完整实现！**
