--Who are Fetch’s power users?
with user_activity as (
    SELECT 
        u.id as USER_ID,
        count(t.RECEIPT_ID) as total_receipt,
        sum(t.FINAL_SALE) as total_sale
    from USER_TAKEHOME u
    join TRANSACTION_TAKEHOME t
        on u.id = t.USER_ID
    group by 1
),

average as(
    select 
        avg(total_receipt) as avg_receipt, 
        avg(total_sale) as avg_sale
    FROM user_activity
)

select 
    u.USER_ID, 
    u.total_receipt,
    u.total_sale
from user_activity u 
cross join average a 
where u.total_receipt > a.avg_receipt
    or u.total_sale > a.avg_sale
order by u.total_sale desc, u.total_receipt desc
limit 10

  
--Which is the leading brand in the Dips & Salsa category?
select 
    p.BRAND,
    sum(t.FINAL_SALE) as total_sale
from TRANSACTION_TAKEHOME t 
join PRODUCTS_TAKEHOME p
    on t.BARCODE = p.BARCODE
where p.CATEGORY_2 = "Dips & Salsa"
group by 1
order by total_sale desc
limit 1

--At what percent has Fetch grown year over year?
WITH yearly_user_count AS (
    SELECT 
        strftime('%Y', u.CREATED_DATE) AS year,
        COUNT(*) AS user_count
    FROM USER_TAKEHOME u
    GROUP BY 1
)
SELECT 
    y1.year,
    y1.user_count,
    COALESCE(
        ROUND((y1.user_count - 
            (SELECT y2.user_count FROM yearly_user_count y2 WHERE y2.year = y1.year - 1)) 
            * 100.0 / 
            (SELECT y2.user_count FROM yearly_user_count y2 WHERE y2.year = y1.year - 1), 2),
        0
    ) AS yoy_growth_percentage
FROM yearly_user_count y1
ORDER BY y1.year;
