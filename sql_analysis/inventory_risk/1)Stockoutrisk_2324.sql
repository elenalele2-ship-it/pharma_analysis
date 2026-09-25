/* Stockout risk analysis - 2024
 which product are at risk stockout?
Stockout risk in accord to the safety policy.  
*/




WITH safety_level AS (

SELECT 
s.productid,
s.date,
round(avg(s.quantity_sales)::numeric,2) as avg_quantity_sales,
round(avg(I.inventory_level)::numeric,2) as avg_inventory_month,
pp.safety_stock_months,

-- livello minimo di unita da mentere nel mese
round(avg(s.quantity_sales)::numeric * pp.safety_stock_months::numeric,2) as Min_level_per_month

FROM sales_2023_2024 as s

JOIN inventory_2023_2024 as I ON
I.productid = s.productid
and I.date = s.date

JOIN product_parameter as pp On
pp.productid = s.productid

group by s.productid, s.date, I.inventory_level, pp.safety_stock_months
order by s.productid, s.date
),


case_level AS (
SELECT
*,
case
when Min_level_per_month < avg_inventory_month then 'adequate_stock'
when Min_level_per_month > avg_inventory_month then 'stockout_risk'
else 'avg_level'
end as safety_level
FROM safety_level
)



select DISTINCT
    productid,
    date,
    avg_inventory_month,
    min_level_per_month,
    safety_level
from case_level

where case_level.safety_level = 'stockout_risk'

