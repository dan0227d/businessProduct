
-- 金融商品喜好清單管理系統 V2.0
-- MySQL 8.0
-- 執行順序：
-- 01_schema.sql -> 02_data.sql -> 03_procedures.sql

USE `business_product`;

DELIMITER //

-- ============================================
-- 1. 新增喜好清單
-- ============================================

DROP PROCEDURE IF EXISTS `sp_add_like_list` //

CREATE PROCEDURE `sp_add_like_list`(
    IN p_account VARCHAR(45),
    IN p_no INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price INT DEFAULT NULL;
    DECLARE v_fee_rate DECIMAL(20,10) DEFAULT NULL;

    DECLARE v_product_amount DECIMAL(65,10);
    DECLARE v_total_fee DECIMAL(65,10);
    DECLARE v_total_amount DECIMAL(65,10);

    -- 驗證購買數量
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '購買數量必須大於0';
    END IF;

    -- 驗證扣款帳號
    IF p_account IS NULL OR NOT EXISTS (
        SELECT 1
        FROM user_account
        WHERE account = p_account
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '扣款帳號不存在';
    END IF;

    -- 查詢商品價格及手續費率
    SELECT price, fee_rate
    INTO v_price, v_fee_rate
    FROM product
    WHERE no = p_no;

    IF v_price IS NULL OR v_fee_rate IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品不存在或價格資料不完整';
    END IF;

    -- 計算金額
    SET v_product_amount = v_price * p_quantity;
    SET v_total_fee = v_product_amount * v_fee_rate;
    SET v_total_amount = v_product_amount + v_total_fee;

    INSERT INTO like_list (
        account,
        no,
        purchase_quantity,
        product_amount,
        total_fee,
        total_amount
    )
    VALUES (
        p_account,
        p_no,
        p_quantity,
        v_product_amount,
        v_total_fee,
        v_total_amount
    );
END //


-- ============================================
-- 2. 新增金融商品
-- ============================================

DROP PROCEDURE IF EXISTS `sp_add_product` //

CREATE PROCEDURE `sp_add_product`(
    IN p_product_name VARCHAR(45),
    IN p_price INT,
    IN p_fee_rate DECIMAL(20,10),
    OUT p_no INT
)
BEGIN
    IF p_product_name IS NULL
       OR TRIM(p_product_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品名稱不能為空';
    END IF;

    IF p_price IS NULL OR p_price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品價格必須大於0';
    END IF;

    IF p_fee_rate IS NULL
       OR p_fee_rate < 0
       OR p_fee_rate > 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '手續費率必須介於0到1之間';
    END IF;

    INSERT INTO product (
        product_name,
        price,
        fee_rate
    )
    VALUES (
        p_product_name,
        p_price,
        p_fee_rate
    );

    SET p_no = LAST_INSERT_ID();
END //


-- ============================================
-- 3. 檢查扣款帳號所有權
-- ============================================

DROP PROCEDURE IF EXISTS `sp_check_account_owner` //

CREATE PROCEDURE `sp_check_account_owner`(
    IN p_userid VARCHAR(20),
    IN p_account VARCHAR(45)
)
BEGIN
    SELECT COUNT(*) AS total
    FROM user_account
    WHERE userid = p_userid
      AND account = p_account;
END //


-- ============================================
-- 4. 檢查喜好清單所有權
-- ============================================

DROP PROCEDURE IF EXISTS `sp_check_like_list_owner` //

CREATE PROCEDURE `sp_check_like_list_owner`(
    IN p_userid VARCHAR(20),
    IN p_sn INT
)
BEGIN
    SELECT COUNT(*) AS total
    FROM like_list l
    JOIN user_account ua
        ON l.account = ua.account
    WHERE ua.userid = p_userid
      AND l.sn = p_sn;
END //


-- ============================================
-- 5. 刪除喜好清單
-- ============================================

DROP PROCEDURE IF EXISTS `sp_delete_like_list` //

CREATE PROCEDURE `sp_delete_like_list`(
    IN p_sn INT
)
BEGIN
    DELETE FROM like_list
    WHERE sn = p_sn;
END //


-- ============================================
-- 6. 刪除金融商品
-- ============================================

DROP PROCEDURE IF EXISTS `sp_delete_product` //

CREATE PROCEDURE `sp_delete_product`(
    IN p_no INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM product
        WHERE no = p_no
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品不存在';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM like_list
        WHERE no = p_no
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品已被喜好清單使用，無法刪除';
    END IF;

    DELETE FROM product
    WHERE no = p_no;
END //


-- ============================================
-- 7. 查詢所有喜好清單
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_all_like_list` //

CREATE PROCEDURE `sp_get_all_like_list`()
BEGIN
    SELECT
        l.sn,
        u.userid,
        u.username,
        u.email,
        l.account,
        p.no,
        p.product_name,
        p.price,
        p.fee_rate,
        l.purchase_quantity,
        l.product_amount,
        l.total_fee,
        l.total_amount
    FROM like_list l
    INNER JOIN user_account ua
        ON l.account = ua.account
    INNER JOIN `user` u
        ON ua.userid = u.userid
    INNER JOIN product p
        ON l.no = p.no
    ORDER BY l.sn;
END //


-- ============================================
-- 8. 查詢所有金融商品
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_all_products` //

CREATE PROCEDURE `sp_get_all_products`()
BEGIN
    SELECT
        no,
        product_name,
        price,
        fee_rate
    FROM product;
END //


-- ============================================
-- 9. 查詢所有使用者
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_all_users` //

CREATE PROCEDURE `sp_get_all_users`()
BEGIN
    SELECT
        userid,
        username,
        email,
        account
    FROM `user`
    ORDER BY userid;
END //


-- ============================================
-- 10. 查詢使用者的扣款帳號
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_user_accounts` //

CREATE PROCEDURE `sp_get_user_accounts`(
    IN p_userid VARCHAR(20)
)
BEGIN
    SELECT account
    FROM user_account
    WHERE userid = p_userid
    ORDER BY account;
END //


-- ============================================
-- 11. 透過 Email 查詢使用者
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_user_by_email` //

CREATE PROCEDURE `sp_get_user_by_email`(
    IN p_email VARCHAR(45)
)
BEGIN
    SELECT
        userid,
        username,
        email,
        account,
        password
    FROM `user`
    WHERE email = p_email;
END //


-- ============================================
-- 12. 查詢指定使用者的喜好清單
-- ============================================

DROP PROCEDURE IF EXISTS `sp_get_user_like_list` //

CREATE PROCEDURE `sp_get_user_like_list`(
    IN p_userid VARCHAR(20)
)
BEGIN
    SELECT
        l.sn,
        l.purchase_quantity,
        l.account,
        l.total_fee,
        l.total_amount,
        l.no,
        l.product_amount,
        p.product_name,
        p.price,
        p.fee_rate,
        u.email,
        u.userid,
        u.username
    FROM like_list l
    JOIN user_account ua
        ON l.account = ua.account
    JOIN `user` u
        ON ua.userid = u.userid
    JOIN product p
        ON l.no = p.no
    WHERE ua.userid = p_userid
    ORDER BY l.sn;
END //


-- ============================================
-- 13. 註冊使用者
-- ============================================

DROP PROCEDURE IF EXISTS `sp_register_user` //

CREATE PROCEDURE `sp_register_user`(
    IN p_userid VARCHAR(20),
    IN p_username VARCHAR(45),
    IN p_email VARCHAR(45),
    IN p_password VARCHAR(255),
    IN p_account VARCHAR(45)
)
BEGIN
    IF p_userid IS NULL OR TRIM(p_userid) = ''
       OR p_username IS NULL OR TRIM(p_username) = ''
       OR p_email IS NULL OR TRIM(p_email) = ''
       OR p_password IS NULL OR TRIM(p_password) = ''
       OR p_account IS NULL OR TRIM(p_account) = '' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '註冊資料不可為空';
    END IF;

    INSERT INTO `user` (
        userid,
        username,
        email,
        password,
        account
    )
    VALUES (
        p_userid,
        p_username,
        p_email,
        p_password,
        p_account
    );

    INSERT INTO user_account (
        account,
        userid
    )
    VALUES (
        p_account,
        p_userid
    );
END //


-- ============================================
-- 14. 修改喜好清單
-- ============================================

DROP PROCEDURE IF EXISTS `sp_update_like_list` //

CREATE PROCEDURE `sp_update_like_list`(
    IN p_sn INT,
    IN p_account VARCHAR(45),
    IN p_no INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price INT DEFAULT NULL;
    DECLARE v_fee_rate DECIMAL(20,10) DEFAULT NULL;

    DECLARE v_product_amount DECIMAL(65,10);
    DECLARE v_total_fee DECIMAL(65,10);
    DECLARE v_total_amount DECIMAL(65,10);

    IF NOT EXISTS (
        SELECT 1
        FROM like_list
        WHERE sn = p_sn
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '喜好商品不存在';
    END IF;

    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '購買數量必須大於0';
    END IF;

    IF p_account IS NULL OR NOT EXISTS (
        SELECT 1
        FROM user_account
        WHERE account = p_account
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '扣款帳號不存在';
    END IF;

    SELECT price, fee_rate
    INTO v_price, v_fee_rate
    FROM product
    WHERE no = p_no;

    IF v_price IS NULL OR v_fee_rate IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品不存在或價格資料不完整';
    END IF;

    SET v_product_amount = v_price * p_quantity;
    SET v_total_fee = v_product_amount * v_fee_rate;
    SET v_total_amount = v_product_amount + v_total_fee;

    UPDATE like_list
    SET
        account = p_account,
        no = p_no,
        purchase_quantity = p_quantity,
        product_amount = v_product_amount,
        total_fee = v_total_fee,
        total_amount = v_total_amount
    WHERE sn = p_sn;
END //


-- ============================================
-- 15. 修改金融商品
-- ============================================

DROP PROCEDURE IF EXISTS `sp_update_product` //

CREATE PROCEDURE `sp_update_product`(
    IN p_no INT,
    IN p_product_name VARCHAR(45),
    IN p_price INT,
    IN p_fee_rate DECIMAL(20,10)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM product
        WHERE no = p_no
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品不存在';
    END IF;

    IF p_product_name IS NULL
       OR TRIM(p_product_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品名稱不能為空';
    END IF;

    IF p_price IS NULL OR p_price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品價格必須大於0';
    END IF;

    IF p_fee_rate IS NULL
       OR p_fee_rate < 0
       OR p_fee_rate > 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '手續費率必須介於0到1之間';
    END IF;

    -- 修改商品
    UPDATE product
    SET
        product_name = p_product_name,
        price = p_price,
        fee_rate = p_fee_rate
    WHERE no = p_no;

    -- 同步重新計算喜好清單金額
    UPDATE like_list
    SET
        product_amount =
            p_price * purchase_quantity,

        total_fee =
            p_price * purchase_quantity * p_fee_rate,

        total_amount =
            p_price * purchase_quantity * (1 + p_fee_rate)
    WHERE no = p_no;
END //

DELIMITER ;
