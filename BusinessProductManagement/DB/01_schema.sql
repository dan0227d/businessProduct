
-- 01_schema.sql
-- MySQL 8.0
-- 適用於全新資料庫

CREATE DATABASE IF NOT EXISTS business_product
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

USE business_product;

-- 使用者資料表
CREATE TABLE `user` (
    userid VARCHAR(20) NOT NULL,
    username VARCHAR(45) DEFAULT NULL,
    email VARCHAR(45) DEFAULT NULL,
    account VARCHAR(45) NOT NULL,
    password VARCHAR(45) DEFAULT NULL,

    PRIMARY KEY (userid),
    UNIQUE KEY account_UNIQUE (account),
    UNIQUE KEY email_UNIQUE (email)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- 商品資料表
CREATE TABLE product (
    no INT NOT NULL AUTO_INCREMENT,
    product_name VARCHAR(45) DEFAULT NULL,
    price INT DEFAULT NULL,
    fee_rate DECIMAL(20,10) DEFAULT NULL,

    PRIMARY KEY (no)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- 喜好商品資料表
CREATE TABLE like_list (
    sn INT NOT NULL AUTO_INCREMENT,
    purchase_quantity INT DEFAULT NULL,
    account VARCHAR(45) DEFAULT NULL,
    total_fee DECIMAL(65,10) DEFAULT NULL,
    total_amount DECIMAL(65,10) DEFAULT NULL,
    no INT DEFAULT NULL,
    product_amount DECIMAL(65,10) DEFAULT NULL,

    PRIMARY KEY (sn),

    KEY account_idx (account),
    KEY no_idx (no),

    CONSTRAINT account
        FOREIGN KEY (account)
        REFERENCES `user` (account),

    CONSTRAINT no
        FOREIGN KEY (no)
        REFERENCES product (no)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;
