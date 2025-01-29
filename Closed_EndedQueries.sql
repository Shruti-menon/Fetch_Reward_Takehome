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
  
-- What is the percentage of sales in the Health & Wellness category by generation?
  
WITH Finaltable AS (
    SELECT t.*, p.*,u.*
	FROM TRANSACTION_TAKEHOME as t
	INNER JOIN PRODUCTS_TAKEHOME as p
	ON t.BARCODE = p.BARCODE
	LEFT JOIN USER_TAKEHOME as u
	ON t.USER_ID = u.ID
	WHERE  t.FINAL_SALE is not null and t.FINAL_QUANTITY <> "zero" and t.BARCODE is not null 
),
TotalSales AS (
    SELECT 
        SUM(FINAL_SALE) AS total_sales
    FROM Finaltable
),
HealthWellnessSales AS (
    SELECT 
        CASE 
            WHEN (strftime('%Y', 'now') - strftime('%Y', BIRTH_DATE)) < 26 THEN 'Gen Z'
            WHEN (strftime('%Y', 'now') - strftime('%Y', BIRTH_DATE)) BETWEEN 26 AND 41 THEN 'Millennial'
            WHEN (strftime('%Y', 'now') - strftime('%Y', BIRTH_DATE)) BETWEEN 42 AND 57 THEN 'Gen X'
            ELSE 'Boomer' 
        END AS generation,
        SUM(FINAL_SALE) AS health_wellness_sales
    FROM Finaltable
    WHERE CATEGORY_1 = 'Health & Wellness'
    GROUP BY generation
)

SELECT hws.generation,
    hws.health_wellness_sales,
    ROUND((hws.health_wellness_sales * 100.0 / ts.total_sales), 2) AS percentage_of_total_sales
FROM HealthWellnessSales AS hws
CROSS JOIN TotalSales AS ts
ORDER BY percentage_of_total_sales DESC;
