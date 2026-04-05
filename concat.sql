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

SELECT * FROM customer ORDER BY birth_day DESC LIMIT 10;

-- RANK() はウィンドウ関数で、指定した順序に基づいて順位を付ける
-- OVER(ORDER BY amount DESC) は「amountの降順で順位を計算する」ウィンドウ定義
-- 同じ値が複数ある場合、同順位となり次の順位はスキップされる（例: 1,1,3,4...）
SELECT customer_id, amount, RANK() OVER (
        ORDER BY amount DESC
    ) AS ranking
FROM receipt
LIMIT 10;

SELECT customer_id, amount, ROW_NUMBER() OVER (
        ORDER BY amount DESC
    ) AS ranking
FROM receipt
LIMIT 10;

SELECT COUNT(1) FROM receipt;

SELECT COUNT(*) FROM receipt;

SELECT COUNT(DISTINCT customer_id) FROM receipt;

SELECT store_cd, SUM(amount) AS amount, SUM(quantity) AS quantity
FROM receipt
GROUP BY
    store_cd;

SELECT
    customer_id,
    MAX(sales_ymd) AS last_purchase_date
FROM receipt
GROUP BY
    customer_id
LIMIT 10;

SELECT customer_id, MIN(sales_ymd)
FROM receipt
GROUP BY
    customer_id
LIMIT 10;

SELECT customer_id, MAX(sales_ymd), MIN(sales_ymd)
FROM receipt
GROUP BY
    customer_id
HAVING
    MAX(sales_ymd) != MIN(sales_ymd)
LIMIT 10;

SELECT store_cd, AVG(amount) AS avg_amount
FROM receipt
GROUP BY
    store_cd
ORDER BY avg_amount DESC
LIMIT 5;

-- PERCENTILE_CONT(0.5) は連続パーセンタイル関数で、指定した分位数(0.5=50パーセンタイル=中央値)を計算する
-- WITHIN GROUP (ORDER BY amount) は「amountを昇順に並べた中での」パーセンタイル位置を指定する
-- 値が偶数個の場合、中央2値の平均値を返す（連続補間）
-- GROUP BY store_cd で店舗ごとに中央値を集計している
SELECT store_cd, PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY amount
    ) AS amount_50per
FROM receipt
GROUP BY
    store_cd
ORDER BY amount_50per DESC
LIMIT 5;

-- コード例1: window関数や分析関数で最頻値を集計する
-- S-029: レシート明細データ（receipt）に対し、店舗コード（store_cd）ごとに商品コード（product_cd）の最頻値を求め、10件表示させよ。
-- 【解説】
-- ステップ1: product_cnt CTE
--   store_cd × product_cd の組み合わせごとに出現回数(mode_cnt)を集計する
-- ステップ2: product_mode CTE
--   RANK() OVER(PARTITION BY store_cd ORDER BY mode_cnt DESC)
--     → 店舗ごと(PARTITION BY store_cd)に出現回数の多い順(ORDER BY mode_cnt DESC)で順位付け
--     → 同数1位が複数ある場合はすべて rnk=1 になる
-- ステップ3: メインクエリ
--   rnk=1 の行のみ抽出することで、各店舗の最頻値(最も多く売れた商品)を取得する
WITH
    product_cnt AS (
        SELECT store_cd, product_cd, COUNT(1) AS mode_cnt
        FROM receipt
        GROUP BY
            store_cd,
            product_cd
    ),
    product_mode AS (
        SELECT
            store_cd,
            product_cd,
            mode_cnt,
            RANK() OVER (
                PARTITION BY
                    store_cd
                ORDER BY mode_cnt DESC
            ) AS rnk
        FROM product_cnt
    )
SELECT store_cd, product_cd, mode_cnt
FROM product_mode
WHERE
    rnk = 1
ORDER BY store_cd, product_cd
LIMIT 10;

-- コード例2: MODE()を使う簡易ケース（早いが最頻値が複数の場合は一つだけ選ばれる）
-- MODE() は最頻値を返す集約関数
-- WITHIN GROUP (ORDER BY product_cd) は「product_cd の順序に基づいて最頻値を決定する」指定
--   → 同じ出現回数の値が複数ある場合、ORDER BY の順序で最初に来る値が返される
-- コード例1(RANK使用)との違い: 最頻値が複数あっても1行しか返さない
SELECT store_cd, MODE() WITHIN GROUP (
        ORDER BY product_cd
    )
FROM receipt
GROUP BY
    store_cd
ORDER BY store_cd
LIMIT 10;