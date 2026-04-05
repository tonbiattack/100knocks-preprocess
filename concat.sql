SELECT
    sales_ymd AS sales_date,
    customer_id,
    product_cd,
    amount
FROM receipt
LIMIT 10;

SELECT
    sales_ymd,
    customer_id,
    product_cd,
    amount
FROM receipt
WHERE
    customer_id = 'CS018205000001';

SELECT
    sales_ymd,
    customer_id,
    product_cd,
    amount
FROM receipt
WHERE
    customer_id = 'CS018205000001'
    AND amount >= 1000;

SELECT
    sales_ymd,
    customer_id,
    product_cd,
    quantity,
    amount
FROM receipt
WHERE
    customer_id = 'CS018205000001'
    AND (
        amount >= 1000
        OR quantity >= 5
    );

SELECT
    sales_ymd,
    customer_id,
    product_cd,
    amount
FROM receipt
WHERE
    customer_id = 'CS018205000001'
    AND amount BETWEEN 1000 AND 2000;

SELECT
    sales_ymd,
    customer_id,
    product_cd,
    amount
FROM receipt
WHERE
    customer_id = 'CS018205000001'
    AND product_cd != 'P071401019';

SELECT *
FROM store
WHERE
    prefecture_cd != '13'
    AND floor_area <= 900;

SELECT * FROM store WHERE store_cd LIKE 'S14%' LIMIT 10;

SELECT * FROM customer WHERE customer_id LIKE '%1' LIMIT 10;

SELECT * FROM store WHERE address LIKE '%横浜市%';

SELECT * FROM customer WHERE status_cd ~ '^[A-F]' LIMIT 10;
-- ~ は正規表現マッチ演算子（大文字小文字を区別する）
-- '[1-9]$' は「文字列の末尾($)が1〜9のいずれかの数字([1-9])」にマッチする正規表現
SELECT * FROM customer WHERE status_cd ~ '[1-9]$' LIMIT 10;

SELECT * FROM customer WHERE status_cd ~ '^[A-F].*[1-9]$' LIMIT 10;

SELECT * FROM store WHERE tel_no ~ '^[0-9]{3}-[0-9]{3}-[0-9]{4}$';

SELECT * FROM customer ORDER BY birth_day LIMIT 10;