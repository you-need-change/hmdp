/*
 Navicat Premium Data Transfer

 Source Server         : local
 Source Server Type    : MySQL
 Source Server Version : 50622
 Source Host           : localhost:3306
 Source Schema         : hmdp

 Target Server Type    : MySQL
 Target Server Version : 50622
 File Encoding         : 65001

 Date: 14/03/2022 21:38:11
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE hmdp;
USE hmdp;
DROP TABLE IF EXISTS `tb_shop_type`;
CREATE TABLE `tb_shop_type` (
                                `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                                `name` varchar(32) DEFAULT NULL,
                                `icon` varchar(255) DEFAULT NULL,
                                `sort` int(3) UNSIGNED DEFAULT NULL,
                                `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                                `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `tb_shop_type` (`id`, `name`, `icon`, `sort`) VALUES
                                                              (1, '美食', '/types/ms.png', 1),
                                                              (2, 'KTV', '/types/KTV.png', 2),
                                                              (3, '丽人·美发', '/types/lrmf.png', 3);

DROP TABLE IF EXISTS `tb_shop`;
CREATE TABLE `tb_shop` (
                           `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                           `name` varchar(128) NOT NULL,
                           `type_id` bigint(20) UNSIGNED NOT NULL,
                           `images` varchar(1024) NOT NULL,
                           `area` varchar(128) DEFAULT NULL,
                           `address` varchar(255) NOT NULL,
                           `x` double UNSIGNED NOT NULL,
                           `y` double UNSIGNED NOT NULL,
                           `avg_price` bigint(10) UNSIGNED DEFAULT NULL,
                           `sold` int(10) UNSIGNED NOT NULL DEFAULT 0,
                           `comments` int(10) UNSIGNED NOT NULL DEFAULT 0,
                           `score` int(2) UNSIGNED NOT NULL DEFAULT 0,
                           `open_hours` varchar(32) DEFAULT NULL,
                           `create_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
                           `update_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           PRIMARY KEY (`id`),
                           KEY `idx_shop_type_id` (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- ----------------------------
-- Records of tb_sign
-- ----------------------------

-- ----------------------------
-- Table structure for tb_user
-- ----------------------------
DROP TABLE IF EXISTS `tb_user`;
CREATE TABLE `tb_user`  (
                            `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
                            `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '手机号码',
                            `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '密码，加密存储',
                            `nick_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '昵称，默认是用户id',
                            `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '人物头像',
                            `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            PRIMARY KEY (`id`) USING BTREE,
                            UNIQUE INDEX `uniqe_key_phone`(`phone`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1010 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

DROP TABLE IF EXISTS `tb_user_info`;
CREATE TABLE `tb_user_info` (
                                `user_id` bigint(20) UNSIGNED NOT NULL,
                                `city` varchar(64) DEFAULT NULL,
                                `introduce` varchar(128) DEFAULT NULL,
                                `fans` int(8) UNSIGNED DEFAULT 0,
                                `followee` int(8) UNSIGNED DEFAULT 0,
                                `gender` tinyint(1) DEFAULT NULL,
                                `birthday` date DEFAULT NULL,
                                `credits` int(8) UNSIGNED DEFAULT 0,
                                `level` tinyint(1) UNSIGNED DEFAULT 0,
                                `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `tb_shop` (`id`, `name`, `type_id`, `images`, `area`, `address`, `x`, `y`, `avg_price`, `sold`, `comments`, `score`, `open_hours`) VALUES
                                                                                                                                                   (1, '103茶餐厅', 1, 'https://qcloud.dpfile.com/pc/jiclIsCKmOI2arxKN1Uf0Hx3PucIJH8q0QSz-Z8llzcN56-_QiKuOvyio1OOxsRtFoXqu0G3iT2T27qat3WhLVEuLYk00OmSS1IdNpm8K8sG4JN9RIm2mTKcbLtc2o2vfCF2ubeXzk49OsGrXt_KYDCngOyCwZK-s3fqawWswzk.jpg', '大关', '金华路锦昌文华苑29号', 120.149192, 30.316078, 80, 4215, 3035, 37, '10:00-22:00'),
                                                                                                                                                   (2, '开乐迪KTV', 2, 'https://p0.meituan.net/joymerchant/a575fd4adb0b9099c5c410058148b307-674435191.jpg', '运河上街', '台州路2号运河上街购物中心F4', 120.149093, 30.324666, 67, 26891, 902, 37, '00:00-24:00');

INSERT INTO `tb_shop` (`id`, `name`, `type_id`, `images`, `area`, `address`, `x`, `y`, `avg_price`, `sold`, `comments`, `score`, `open_hours`) VALUES
                                                                                                                                                   (3, '104茶餐厅', 1, 'https://qcloud.dpfile.com/pc/jiclIsCKmOI2arxKN1Uf0Hx3PucIJH8q0QSz-Z8llzcN56-_QiKuOvyio1OOxsRtFoXqu0G3iT2T27qat3WhLVEuLYk00OmSS1IdNpm8K8sG4JN9RIm2mTKcbLtc2o2vfCF2ubeXzk49OsGrXt_KYDCngOyCwZK-s3fqawWswzk.jpg', '大关', '金华路锦昌文华苑29号', 120.149192, 30.316078, 80, 4215, 6666, 37, '10:00-22:00'),
                                                                                                                                                   (4, '开乐迪KTV分店', 2, 'https://p0.meituan.net/joymerchant/a575fd4adb0b9099c5c410058148b307-674435191.jpg', '运河上街', '台州路2号运河上街购物中心F4', 120.149093, 30.324666, 67, 26891, 90, 37, '00:00-24:00');

DROP TABLE IF EXISTS `tb_voucher`;
CREATE TABLE `tb_voucher` (
                              `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                              `shop_id` bigint(20) UNSIGNED DEFAULT NULL,
                              `title` varchar(255) NOT NULL,
                              `sub_title` varchar(255) DEFAULT NULL,
                              `rules` varchar(1024) DEFAULT NULL,
                              `pay_value` bigint(10) UNSIGNED NOT NULL,
                              `actual_value` bigint(10) NOT NULL,
                              `type` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
                              `status` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
                              `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                              PRIMARY KEY (`id`),
                              KEY `idx_voucher_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `tb_voucher` (`id`, `shop_id`, `title`, `sub_title`, `rules`, `pay_value`, `actual_value`, `type`, `status`) VALUES
                                                                                                                             (1, 1, '50元代金券', '周一至周日均可使用', '全场通用\\n无需预约\\n仅限堂食', 4750, 5000, 0, 1),
                                                                                                                             (2, 1, '限时秒杀券', '秒杀活动专享', '每人限购一张', 100, 1000, 1, 1);

DROP TABLE IF EXISTS `tb_seckill_voucher`;
CREATE TABLE `tb_seckill_voucher` (
                                      `voucher_id` bigint(20) UNSIGNED NOT NULL,
                                      `stock` int(8) NOT NULL,
                                      `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      `begin_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      `end_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                      PRIMARY KEY (`voucher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `tb_seckill_voucher` (`voucher_id`, `stock`, `begin_time`, `end_time`) VALUES
    (2, 100, '2021-01-01 00:00:00', '2099-12-31 23:59:59');

DROP TABLE IF EXISTS `tb_voucher_order`;
CREATE TABLE `tb_voucher_order` (
                                    `id` bigint(20) NOT NULL,
                                    `user_id` bigint(20) UNSIGNED NOT NULL,
                                    `voucher_id` bigint(20) UNSIGNED NOT NULL,
                                    `pay_type` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
                                    `status` tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
                                    `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                    `pay_time` timestamp NULL DEFAULT NULL,
                                    `use_time` timestamp NULL DEFAULT NULL,
                                    `refund_time` timestamp NULL DEFAULT NULL,
                                    `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                    PRIMARY KEY (`id`),
                                    UNIQUE KEY `idx_user_voucher` (`user_id`, `voucher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `tb_blog`;
CREATE TABLE `tb_blog` (
                           `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                           `shop_id` bigint(20) UNSIGNED DEFAULT NULL,
                           `user_id` bigint(20) UNSIGNED NOT NULL,
                           `title` varchar(255) NOT NULL,
                           `images` varchar(2048) NOT NULL,
                           `content` varchar(2048) NOT NULL,
                           `liked` int(8) UNSIGNED NOT NULL DEFAULT 0,
                           `comments` int(8) UNSIGNED NOT NULL DEFAULT 0,
                           `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           PRIMARY KEY (`id`),
                           KEY `idx_blog_user_id` (`user_id`),
                           KEY `idx_blog_liked` (`liked`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of tb_blog
-- ----------------------------
INSERT INTO `tb_blog` VALUES (4, 4, 1010, '无尽浪漫的夜晚丨在万花丛中摇晃着红酒杯🍷品战斧牛排🥩', '/imgs/blogs/7/14/4771fefb-1a87-4252-816c-9f7ec41ffa4a.jpg,/imgs/blogs/4/10/2f07e3c9-ddce-482d-9ea7-c21450f8d7cd.jpg,/imgs/blogs/2/6/b0756279-65da-4f2d-b62a-33f74b06454a.jpg,/imgs/blogs/10/7/7e97f47d-eb49-4dc9-a583-95faa7aed287.jpg,/imgs/blogs/1/2/4a7b496b-2a08-4af7-aa95-df2c3bd0ef97.jpg,/imgs/blogs/14/3/52b290eb-8b5d-403b-8373-ba0bb856d18e.jpg', '生活就是一半烟火·一半诗意<br/>手执烟火谋生活·心怀诗意以谋爱·<br/>当然<br/>\r\n男朋友给不了的浪漫要学会自己给🍒<br/>\n无法重来的一生·尽量快乐.<br/><br/>🏰「小筑里·神秘浪漫花园餐厅」🏰<br/><br/>\n💯这是一家最最最美花园的西餐厅·到处都是花餐桌上是花前台是花  美好无处不在\n品一口葡萄酒，维亚红酒马瑟兰·微醺上头工作的疲惫消失无际·生如此多娇🍃<br/><br/>📍地址:延安路200号(家乐福面)<br/><br/>🚌交通:地铁①号线定安路B口出右转过下通道右转就到啦～<br/><br/>--------------🥣菜品详情🥣---------------<br/><br/>「战斧牛排]<br/>\n超大一块战斧牛排经过火焰的炙烤发出阵阵香，外焦里嫩让人垂涎欲滴，切开牛排的那一刻，牛排的汁水顺势流了出来，分熟的牛排肉质软，简直细嫩到犯规，一刻都等不了要放入嘴里咀嚼～<br/><br/>「奶油培根意面」<br/>太太太好吃了💯<br/>我真的无法形容它的美妙，意面混合奶油香菇的香味真的太太太香了，我真的舔盘了，一丁点美味都不想浪费‼️<br/><br/><br/>「香菜汁烤鲈鱼」<br/>这个酱是辣的 真的绝好吃‼️<br/>鲈鱼本身就很嫩没什么刺，烤过之后外皮酥酥的，鱼肉蘸上酱料根本停不下来啊啊啊啊<br/>能吃辣椒的小伙伴一定要尝尝<br/><br/>非常可 好吃子🍽\n<br/>--------------🍃个人感受🍃---------------<br/><br/>【👩🏻‍🍳服务】<br/>小姐姐特别耐心的给我们介绍彩票 <br/>推荐特色菜品，拍照需要帮忙也是尽心尽力配合，太爱他们了<br/><br/>【🍃环境】<br/>比较有格调的西餐厅 整个餐厅的布局可称得上的万花丛生 有种在人间仙境的感觉🌸<br/>集美食美酒与鲜花为一体的风格店铺 令人向往<br/>烟火皆是生活 人间皆是浪漫<br/>', 1, 104, '2021-12-28 19:50:01', '2022-03-10 14:26:34');
INSERT INTO `tb_blog` VALUES (5, 4, 1071, '人均30💰杭州这家港式茶餐厅我疯狂打call‼️', '/imgs/blogs/4/7/863cc302-d150-420d-a596-b16e9232a1a6.jpg,/imgs/blogs/11/12/8b37d208-9414-4e78-b065-9199647bb3e3.jpg,/imgs/blogs/4/1/fa74a6d6-3026-4cb7-b0b6-35abb1e52d11.jpg,/imgs/blogs/9/12/ac2ce2fb-0605-4f14-82cc-c962b8c86688.jpg,/imgs/blogs/4/0/26a7cd7e-6320-432c-a0b4-1b7418f45ec7.jpg,/imgs/blogs/15/9/cea51d9b-ac15-49f6-b9f1-9cf81e9b9c85.jpg', '又吃到一家好吃的茶餐厅🍴环境是怀旧tvb港风📺边吃边拍照片📷几十种菜品均价都在20+💰可以是很平价了！<br>·<br>店名：九记冰厅(远洋店)<br>地址：杭州市丽水路远洋乐堤港负一楼（溜冰场旁边）<br>·<br>✔️黯然销魂饭（38💰）<br>这碗饭我吹爆！米饭上盖满了甜甜的叉烧 还有两颗溏心蛋🍳每一粒米饭都裹着浓郁的酱汁 光盘了<br>·<br>✔️铜锣湾漏奶华（28💰）<br>黄油吐司烤的脆脆的 上面洒满了可可粉🍫一刀切开 奶盖流心像瀑布一样流出来  满足<br>·<br>✔️神仙一口西多士士（16💰）<br>简简单单却超级好吃！西多士烤的很脆 黄油味浓郁 面包体超级柔软 上面淋了炼乳<br>·<br>✔️怀旧五柳炸蛋饭（28💰）<br>四个鸡蛋炸成蓬松的炸蛋！也太好吃了吧！还有大块鸡排 上淋了酸甜的酱汁 太合我胃口了！！<br>·<br>✔️烧味双拼例牌（66💰）<br>选了烧鹅➕叉烧 他家烧腊品质真的惊艳到我！据说是每日广州发货 到店现烧现卖的黑棕鹅 每口都是正宗的味道！肉质很嫩 皮超级超级酥脆！一口爆油！叉烧肉也一点都不柴 甜甜的很入味 搭配梅子酱很解腻 ！<br>·<br>✔️红烧脆皮乳鸽（18.8💰）<br>乳鸽很大只 这个价格也太划算了吧， 肉质很有嚼劲 脆皮很酥 越吃越香～<br>·<br>✔️大满足小吃拼盘（25💰）<br>翅尖➕咖喱鱼蛋➕蝴蝶虾➕盐酥鸡<br>zui喜欢里面的咖喱鱼！咖喱酱香甜浓郁！鱼蛋很q弹～<br>·<br>✔️港式熊仔丝袜奶茶（19💰）<br>小熊🐻造型的奶茶冰也太可爱了！颜值担当 很地道的丝袜奶茶 茶味特别浓郁～<br>·', 1, 0, '2021-12-28 20:57:49', '2022-03-10 09:21:39');
INSERT INTO `tb_blog` VALUES (6, 1, 1072, '杭州周末好去处｜💰50就可以骑马啦🐎', '/imgs/blogs/blog1.jpg', '杭州周末好去处｜💰50就可以骑马啦🐎', 1, 0, '2022-01-11 16:05:47', '2022-03-10 09:21:41');
INSERT INTO `tb_blog` VALUES (7, 1, 1073, '杭州周末好去处｜💰50就可以骑马啦🐎', '/imgs/blogs/blog1.jpg', '杭州周末好去处｜💰50就可以骑马啦🐎', 1, 0, '2022-01-11 16:05:47', '2022-03-10 09:21:42');

DROP TABLE IF EXISTS `tb_blog_comments`;
CREATE TABLE `tb_blog_comments` (
                                    `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                                    `user_id` bigint(20) UNSIGNED NOT NULL,
                                    `blog_id` bigint(20) UNSIGNED NOT NULL,
                                    `parent_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
                                    `answer_id` bigint(20) UNSIGNED NOT NULL DEFAULT 0,
                                    `content` varchar(255) NOT NULL,
                                    `liked` int(8) UNSIGNED NOT NULL DEFAULT 0,
                                    `status` tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
                                    `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                    `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                    PRIMARY KEY (`id`),
                                    KEY `idx_blog_comments_blog_id` (`blog_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `tb_follow`;
CREATE TABLE `tb_follow` (
                             `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
                             `user_id` bigint(20) UNSIGNED NOT NULL,
                             `follow_user_id` bigint(20) UNSIGNED NOT NULL,
                             `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             PRIMARY KEY (`id`),
                             UNIQUE KEY `idx_user_follow` (`user_id`, `follow_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `tb_follow` (`id`, `user_id`, `follow_user_id`, `create_time`) VALUES
    (1, 1071, 1010, '2021-01-01 09:01:01');
INSERT INTO `tb_follow` (`id`, `user_id`, `follow_user_id`, `create_time`) VALUES
    (2, 1071, 1072, '2021-01-01 09:01:31');
INSERT INTO `tb_follow` (`id`, `user_id`, `follow_user_id`, `create_time`) VALUES
    (3, 1071, 1073, '2021-01-01 09:01:59');
INSERT INTO `tb_follow` (`id`, `user_id`, `follow_user_id`, `create_time`) VALUES
    (4, 1071, 1074, '2021-01-01 09:02:01');