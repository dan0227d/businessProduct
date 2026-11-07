-- 金融商品喜好清單管理系統 V2.0
-- MySQL 8.0；僅供全新資料庫初始化使用
-- 執行順序：01_schema.sql -> 02_data.sql -> 03_procedures.sql

CREATE DATABASE IF NOT EXISTS `business_product`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `business_product`;

-- 順序依外鍵依賴關係：user/product -> user_account -> like_list

-- user
CREATE TABLE `user` (
  `userid` varchar(20) NOT NULL,
  `username` varchar(45) DEFAULT NULL,
  `email` varchar(45) DEFAULT NULL,
  `account` varchar(45) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`userid`),
  UNIQUE KEY `account_UNIQUE` (`account`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- product
CREATE TABLE `product` (
  `no` int NOT NULL AUTO_INCREMENT,
  `product_name` varchar(45) DEFAULT NULL,
  `price` int DEFAULT NULL,
  `fee_rate` decimal(20,10) DEFAULT NULL,
  PRIMARY KEY (`no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- user_account
CREATE TABLE `user_account` (
  `account` varchar(45) NOT NULL,
  `userid` varchar(20) NOT NULL,
  PRIMARY KEY (`account`),
  KEY `fk_user_account_user` (`userid`),
  CONSTRAINT `fk_user_account_user` FOREIGN KEY (`userid`) REFERENCES `user` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- like_list
CREATE TABLE `like_list` (
  `sn` int NOT NULL AUTO_INCREMENT,
  `purchase_quantity` int DEFAULT NULL,
  `account` varchar(45) DEFAULT NULL,
  `total_fee` decimal(65,10) DEFAULT NULL,
  `total_amount` decimal(65,10) DEFAULT NULL,
  `no` int DEFAULT NULL,
  `product_amount` decimal(65,10) DEFAULT NULL,
  PRIMARY KEY (`sn`),
  KEY `account_idx` (`account`),
  KEY `no_idx` (`no`),
  CONSTRAINT `account` FOREIGN KEY (`account`) REFERENCES `user_account` (`account`),
  CONSTRAINT `no` FOREIGN KEY (`no`) REFERENCES `product` (`no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
