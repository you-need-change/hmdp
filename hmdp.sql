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