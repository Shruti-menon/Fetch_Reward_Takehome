--Who are Fetch’s power users?
with user_activity as (
    SELECT 
        u.id as USER_ID,
        count(t.RECEIPT_ID) as total_receipt,
        sum(t.FINAL_SALE) as total_sale
    from USER_TAKEHOME u
    join TRANSACTION_TAKEHOME t
        on u.id = t.USER_ID
    WHERE t.FINAL_SALE is not null 
    AND t.FINAL_QUANTITY <> "zero"
    AND t.BARCODE is not null
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
AND t.FINAL_SALE is not null 
AND t.FINAL_QUANTITY <> "zero"
AND t.BARCODE is not null
group by 1
order by total_sale desc
limit 1

--At what percent has Fetch grown year over year?
with yearly_user_count as (
	select 
		strftime('%Y', u.CREATED_DATE) as year,
		count(*) as user_count
	from USER_TAKEHOME u
	GROUP by 1
),
growth_rate as (
	SELECT
		year,
		user_count,
		lag(user_count) over (order by year) as previous_year_count,
		round((user_count - lag(user_count) over (order by year)) * 100 /  lag(user_count) over (order by year), 2) as yoy_growth
		from yearly_user_count

)

select 
	year,
	user_count,
	coalesce (yoy_growth, 0) as yoy_growth_percentage
from growth_rate
order by 1
