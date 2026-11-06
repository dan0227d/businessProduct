
-- 02_data.sql

USE business_product;

-- 使用者測試資料
INSERT INTO `user` (
    userid,
    username,
    email,
    account,
    password
)
VALUES
('A00001', '王小明', 'test01@example.com', '1111', NULL),
('A00002', '陳小華', 'test02@example.com', '1112', NULL),
('A00003', '林小美', 'test03@example.com', '1113', NULL);

-- 商品測試資料
INSERT INTO product (
    no,
    product_name,
    price,
    fee_rate
)
VALUES
(2, '無線滑鼠', 890, 0.0300000000),
(7, '有線滑鼠', 300, 0.0010000000),
(8, '有線滑鼠 pro', 120, 0.4000000000),
(10, '測試金融商品', 10, 0.0500000000),
(13, 'Postman修改商品', 1500, 0.1000000000),
(14, 'Transaction測試商品', 2000, 0.0500000000);

-- 喜好清單測試資料
INSERT INTO like_list (
    sn,
    purchase_quantity,
    account,
    total_fee,
    total_amount,
    no,
    product_amount
)
VALUES
(4, 2, '1111', 96.0000000000, 336.0000000000, 8, 240.0000000000),
(5, 2, '1111', 1.0000000000, 21.0000000000, 10, 20.0000000000),
(7, 1, '1111', 48.0000000000, 168.0000000000, 8, 120.0000000000),
(8, 1, '1112', 48.0000000000, 168.0000000000, 8, 120.0000000000),
(9, 2, '1112', 300.0000000000, 3300.0000000000, 13, 3000.0000000000);

-- 保留原始資料庫的下一個 AUTO_INCREMENT 編號
ALTER TABLE product AUTO_INCREMENT = 16;
ALTER TABLE like_list AUTO_INCREMENT = 11;
