
-- 03_procedures.sql

USE business_product;

DELIMITER //

-- =====================================
-- 1. 查詢所有使用者
-- =====================================

DROP PROCEDURE IF EXISTS sp_get_all_users //

CREATE PROCEDURE sp_get_all_users()
BEGIN
    SELECT
        userid,
        username,
        email,
        account
    FROM `user`
    ORDER BY userid;
END //


-- =====================================
-- 2. 查詢所有商品
-- =====================================

DROP PROCEDURE IF EXISTS sp_get_all_products //

CREATE PROCEDURE sp_get_all_products()
BEGIN
    SELECT
        no,
        product_name,
        price,
        fee_rate
    FROM product;
END //


-- =====================================
-- 3. 新增商品
-- =====================================

DROP PROCEDURE IF EXISTS sp_add_product //

CREATE PROCEDURE sp_add_product(
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

    -- 回傳新商品編號
    SET p_no = LAST_INSERT_ID();

END //


-- =====================================
-- 4. 修改商品
-- =====================================

DROP PROCEDURE IF EXISTS sp_update_product //

CREATE PROCEDURE sp_update_product(
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

    -- 同步更新所有引用該商品的喜好清單
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


-- =====================================
-- 5. 刪除商品
-- =====================================

DROP PROCEDURE IF EXISTS sp_delete_product //

CREATE PROCEDURE sp_delete_product(
    IN p_no INT
)
BEGIN

    -- 商品是否存在
    IF NOT EXISTS (
        SELECT 1
        FROM product
        WHERE no = p_no
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品不存在';

    END IF;

    -- 商品是否被喜好清單引用
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


-- =====================================
-- 6. 查詢所有喜好清單
-- =====================================

DROP PROCEDURE IF EXISTS sp_get_all_like_list //

CREATE PROCEDURE sp_get_all_like_list()
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

    INNER JOIN `user` u
        ON l.account = u.account

    INNER JOIN product p
        ON l.no = p.no

    ORDER BY l.sn;

END //


-- =====================================
-- 7. 新增喜好清單
-- =====================================

DROP PROCEDURE IF EXISTS sp_add_like_list //

CREATE PROCEDURE sp_add_like_list(
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
        FROM `user`
        WHERE account = p_account
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '扣款帳號不存在';

    END IF;

    -- 查詢商品價格與費率
    SELECT
        price,
        fee_rate
    INTO
        v_price,
        v_fee_rate
    FROM product
    WHERE no = p_no;

    IF v_price IS NULL OR v_fee_rate IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品不存在或價格資料不完整';

    END IF;

    -- 商品總金額
    SET v_product_amount =
        v_price * p_quantity;

    -- 手續費總額
    SET v_total_fee =
        v_product_amount * v_fee_rate;

    -- 預計扣款總金額
    SET v_total_amount =
        v_product_amount + v_total_fee;

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


-- =====================================
-- 8. 修改喜好清單
-- =====================================

DROP PROCEDURE IF EXISTS sp_update_like_list //

CREATE PROCEDURE sp_update_like_list(
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

    -- 確認喜好清單存在
    IF NOT EXISTS (
        SELECT 1
        FROM like_list
        WHERE sn = p_sn
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '喜好商品不存在';

    END IF;

    -- 驗證購買數量
    IF p_quantity IS NULL OR p_quantity <= 0 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '購買數量必須大於0';

    END IF;

    -- 驗證扣款帳號
    IF p_account IS NULL OR NOT EXISTS (
        SELECT 1
        FROM `user`
        WHERE account = p_account
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '扣款帳號不存在';

    END IF;

    -- 查詢商品價格與費率
    SELECT
        price,
        fee_rate
    INTO
        v_price,
        v_fee_rate
    FROM product
    WHERE no = p_no;

    IF v_price IS NULL OR v_fee_rate IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '商品不存在或價格資料不完整';

    END IF;

    -- 重新計算商品金額
    SET v_product_amount =
        v_price * p_quantity;

    -- 重新計算手續費
    SET v_total_fee =
        v_product_amount * v_fee_rate;

    -- 重新計算總扣款金額
    SET v_total_amount =
        v_product_amount + v_total_fee;

    -- 更新喜好清單
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


-- =====================================
-- 9. 刪除喜好清單
-- =====================================

DROP PROCEDURE IF EXISTS sp_delete_like_list //

CREATE PROCEDURE sp_delete_like_list(
    IN p_sn INT
)
BEGIN

    DELETE FROM like_list
    WHERE sn = p_sn;

END //

DELIMITER ;
