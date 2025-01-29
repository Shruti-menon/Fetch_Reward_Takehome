-- SQL Queries:

-- What are the top 5 brands by receipts scanned among users 21 and over?
WITH Finaltable AS (
    SELECT t.*, p.*,u.*
	FROM TRANSACTION_TAKEHOME as t
	INNER JOIN PRODUCTS_TAKEHOME as p
	ON t.BARCODE = p.BARCODE
	LEFT JOIN USER_TAKEHOME as u
	ON t.USER_ID = u.ID
	WHERE  t.FINAL_SALE is not null and t.FINAL_QUANTITY <> "zero" and t.BARCODE is not null 
)
SELECT BRAND, CATEGORY_1, count(RECEIPT_ID) as cnt
FROM Finaltable 
WHERE (date() - date(BIRTH_DATE) )>=21
GROUP by BRAND, CATEGORY_1
ORDER By cnt DESC
LIMIT 5

-- What are the top 5 brands by sales among users that have had their account for at least six months?
WITH Finaltable AS (
    SELECT t.*, p.*,u.*
	FROM TRANSACTION_TAKEHOME as t
	INNER JOIN PRODUCTS_TAKEHOME as p
	ON t.BARCODE = p.BARCODE
	LEFT JOIN USER_TAKEHOME as u
	ON t.USER_ID = u.ID
	WHERE  t.FINAL_SALE is not null and t.FINAL_QUANTITY <> "zero" and t.BARCODE is not null 
)
SELECT BRAND, MANUFACTURER, CATEGORY_1,RECEIPT_ID, BARCODE, sum(FINAL_SALE) as quantity
FROM Finaltable 
WHERE datetime(CREATED_DATE) <= datetime('now', '-6 months')
GROUP by BRAND, MANUFACTURER, CATEGORY_1,RECEIPT_ID, BARCODE
ORDER By quantity DESC
LIMIT 5
