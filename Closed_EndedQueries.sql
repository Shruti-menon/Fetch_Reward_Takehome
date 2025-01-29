-- SQL Queries:

-- What are the top 5 brands by receipts scanned among users 21 and over?
WITH Finaltable AS (
SELECT t.*, u.*, p.*
FROM TRANSACTION_TAKEHOME as t
INNER JOIN PRODUCTS_TAKEHOME as p
ON t.BARCODE = p.BARCODE
LEFT JOIN USER_TAKEHOME as u
ON t.USER_ID = u.ID
WHERE t.FINAL_SALE is not null 
AND t.FINAL_QUANTITY <> "zero"
AND t.BARCODE is not null
)
SELECT 
coalesce(BRAND, MANUFACTURER, CATEGORY_2) AS brand_name,
count(receipt_id) AS cnt
FROM Finaltable
WHERE (date()-date(BIRTH_DATE))>=21
GROUP BY 1
ORDER BY cnt DESC

-- What are the top 5 brands by sales among users that have had their account for at least six months?
WITH Finaltable AS (
SELECT t.*, u.*, p.*
FROM TRANSACTION_TAKEHOME as t
INNER JOIN PRODUCTS_TAKEHOME as p
ON t.BARCODE = p.BARCODE
LEFT JOIN USER_TAKEHOME as u
ON t.USER_ID = u.ID
WHERE t.FINAL_SALE is not null 
AND t.FINAL_QUANTITY <> "zero"
AND t.BARCODE is not null
)
SELECT 
coalesce(BRAND, MANUFACTURER, CATEGORY_2) AS brand_name,
sum(FINAL_SALE) as cnt
FROM Finaltable
where CREATED_DATE <=  date('now', '-6 months')
GROUP BY 1
ORDER BY cnt DESC


