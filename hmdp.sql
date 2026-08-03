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