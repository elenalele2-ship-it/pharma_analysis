/* Distribution of expiry risk — 2024
How significant is the expiry risk issue overall?
How many cases fall into high_risk, low_risk, and avg_level?
*/



WITH safety_level AS (

SELECT 
s.productid,
s.date,
round(avg(s.quantity_sales)::numeric,2) as avg_quantity_sales,
round(avg(I.inventory_level)::numeric,2) as avg_inventory_month,
pp.shelf_life_months,
round(avg(quantity_sales*pp.shelf_life_months)::numeric,2) as shelf_life_qsales


FROM sales_2023_2024 as s

JOIN inventory_2023_2024 as I ON
I.productid = s.productid
and I.date = s.date

JOIN product_parameter as pp On
pp.productid = s.productid

group by s.productid, s.date, I.inventory_level, pp.shelf_life_months
order by s.productid, s.date
),


shelf_life_risk_level AS (
select *,
case
when avg_inventory_month > shelf_life_qsales then 'high_risk'   -- troppo stock = rischio scadenza
when avg_inventory_month < shelf_life_qsales then 'low_risk'    -- stock ok, lo smaltisci in tempo
else 'avg_level'
end as shelf_life 
from safety_level
)

SELECT
    shelf_life,
    COUNT(*) as num_casi
FROM shelf_life_risk_level
group by shelf_life


--- 2025

WITH safety_level AS (

SELECT 
s.productid,
s.date,
round(avg(s.quantity_sales)::numeric,2) as avg_quantity_sales,
round(avg(I.inventory_level)::numeric,2) as avg_inventory_month,
pp.shelf_life_months,
round(avg(quantity_sales*pp.shelf_life_months)::numeric,2) as shelf_life_qsales


FROM sales_test_2025 as s

JOIN inventory_test_2025 as I ON
I.productid = s.productid
and I.date = s.date

JOIN product_parameter as pp On
pp.productid = s.productid

group by s.productid, s.date, I.inventory_level, pp.shelf_life_months
order by s.productid, s.date
),


shelf_life_risk_level AS (
select *,
case
when avg_inventory_month > shelf_life_qsales then 'high_risk'   -- troppo stock = rischio scadenza
when avg_inventory_month < shelf_life_qsales then 'low_risk'    -- stock ok, lo smaltisci in tempo
else 'avg_level'
end as shelf_life 
from safety_level
)

SELECT
    shelf_life,
    COUNT(*) as num_casi
FROM shelf_life_risk_level
group by shelf_life