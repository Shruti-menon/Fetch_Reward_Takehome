-- PRODUCTS_TAKEHOME TABLE
SELECT * FROM PRODUCTS_TAKEHOME

-- Null barcode values
select * 
from PRODUCTS_TAKEHOME
where BARCODE is null

-- Number of null values in category1
SELECT BARCODE, CATEGORY_1
FROM PRODUCTS_TAKEHOME
WHERE BARCODE is not null and CATEGORY_1 is NULL
GROUP by 1,2

SELECT *
FROM PRODUCTS_TAKEHOME
WHERE BARCODE is not null and CATEGORY_1 is NULL

--Duplicate barcodes
SELECT barcode, COUNT(*) AS count
FROM PRODUCTS_TAKEHOME
GROUP BY barcode
HAVING COUNT(*) > 1;

-- only duplicate barcodes, can drop these values. Need to check in transaction data. Causes no harm since there is no data in TRANSACTION table.
 select * from PRODUCTS_TAKEHOME where BARCODE in ("017000329260", "052336919068")
 ORDER by BARCODE
 
 --TRANSACTION TABLE
 
 SELECT * FROM TRANSACTION_TAKEHOME
 
 --Testing to see if duplicate barcodes are present in TRANSACTION TABLE, which is NOT present in PRODUCT table.
  SELECT * FROM TRANSACTION_TAKEHOME
  WHERE BARCODE in ("017000329260", "052336919068")
  
  -- DISTINCT  count of RECEIPT_ID
SELECT count (DISTINCT RECEIPT_ID) FROM TRANSACTION_TAKEHOME

-- Eliminating null values from FINAL_SALE and zero value from FINAL_QUANTITY
SELECT * 
FROM TRANSACTION_TAKEHOME
WHERE FINAL_SALE is not null and FINAL_QUANTITY <> "zero"
ORDER BY RECEIPT_ID

--Checking receipt_id's that have barcode value as NULL, this data can be redundant 
SELECT * 
FROM TRANSACTION_TAKEHOME
WHERE FINAL_SALE is not null and FINAL_QUANTITY <> "zero" and BARCODE is null
ORDER BY RECEIPT_ID


--Inner Join with user table, 12 records. We can drop these 12 transactions that have no barcode.
 SELECT t.*, u.*
FROM TRANSACTION_TAKEHOME as t
INNER JOIN USER_TAKEHOME  as u on u.ID = t.USER_ID
WHERE t.FINAL_SALE is not null and t.FINAL_QUANTITY <> "zero" and t.BARCODE is null


--Checking for duplicate receipt_id's
SELECT RECEIPT_ID, count(1) as cnt
FROM TRANSACTION_TAKEHOME
WHERE FINAL_SALE is not null and FINAL_QUANTITY <> "zero" and BARCODE is not null
GROUP By RECEIPT_ID
HAVING cnt>1
ORDER By cnt DESC

--Checking a particular RECEIPT_ID
select * from TRANSACTION_TAKEHOME where RECEIPT_ID = "bedac253-2256-461b-96af-267748e6cecf"

--Checking availability in product and transaction table for a particular RECEIPT_ID
SELECT t.*, p.*
FROM TRANSACTION_TAKEHOME as t
INNER JOIN PRODUCTS_TAKEHOME as p
ON t.BARCODE = p.BARCODE
WHERE  t.FINAL_SALE is not null and t.FINAL_QUANTITY <> "zero" and t.BARCODE is not null and RECEIPT_ID = "eb8b58c3-182a-4623-8492-0b8231b85135"

--Checking the final duplicate RECEIPT_ID
SELECT RECEIPT_ID, count(1) as cnt
FROM TRANSACTION_TAKEHOME as t
INNER JOIN PRODUCTS_TAKEHOME as p
ON t.BARCODE = p.BARCODE
WHERE  t.FINAL_SALE is not null and t.FINAL_QUANTITY <> "zero" and t.BARCODE is not null 
GROUP By RECEIPT_ID
HAVING cnt>1
ORDER By cnt DESC

--CTE (Info table with all the relevant transactions and products, final table)
WITH info AS (
    SELECT t.*, p.*
	FROM TRANSACTION_TAKEHOME as t
	INNER JOIN PRODUCTS_TAKEHOME as p
	ON t.BARCODE = p.BARCODE
	WHERE  t.FINAL_SALE is not null and t.FINAL_QUANTITY <> "zero" and t.BARCODE is not null 
)
SELECT *
FROM info;

--USER TABLE

SELECT * FROM USER_TAKEHOME

-- Checking for duplicates in ID
SELECT  ID, count(1) as cnt
FROM USER_TAKEHOME
GROUP by ID
HAVING cnt>1
ORDER By cnt DESC

--Checking if there are null VALUES
SELECT *
FROM USER_TAKEHOME
WHERE BIRTH_DATE is null

--Checking for particular userID
SELECT *
FROM USER_TAKEHOME
WHERE ID = "60fc1e6deb7585430ff52ee7"

-- INNER JOIN TRANSACTION and USER. Out of 1000000 users, only 262 transactions can be traced.
SELECT t.*, u.*
FROM TRANSACTION_TAKEHOME as t
LEFT JOIN USER_TAKEHOME as u
ON t.USER_ID = u.ID
WHERE ID is not null

-- Out of 262 users, 59 users have valid transactions.
select t.*, p.*, u.*
from TRANSACTION_TAKEHOME t
INNER JOIN PRODUCTS_TAKEHOME p
on t.BARCODE = p.BARCODE
left join USER_TAKEHOME u
on t.USER_ID = u.id
where t.FINAL_SALE is not NULL
and t.FINAL_QUANTITY <> "zero"
and t.BARCODE is not null
and u.id is not null

-- Distinct users with valid transactions
select count(distinct id)
from TRANSACTION_TAKEHOME t
INNER JOIN PRODUCTS_TAKEHOME p
on t.BARCODE = p.BARCODE
left join USER_TAKEHOME u
on t.USER_ID = u.id
where t.FINAL_SALE is not NULL
and t.FINAL_QUANTITY <> "zero"
and t.BARCODE is not null
and u.id is not null

WITH info AS (
    SELECT t.*, p.*
	FROM TRANSACTION_TAKEHOME as t
	INNER JOIN PRODUCTS_TAKEHOME as p
	ON t.BARCODE = p.BARCODE
	WHERE  t.FINAL_SALE is not null and t.FINAL_QUANTITY <> "zero" and t.BARCODE is not null 
)
SELECT i.*, u.*
FROM info as i
LEFT JOIN USER_TAKEHOME as u
ON i.USER_ID = u.ID
