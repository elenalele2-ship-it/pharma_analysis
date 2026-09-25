/* Stockout risk analysis - 2025
 which product are at risk stockout?
Stockout risk in accord to the safety policy.  
*/

with safety_level AS (

select
s.productid,
s.date,
round(avg(s.quantity_sales)::numeric,2) as avg_units_sold_month,
round(avg(I.inventory_level)::numeric,2) as avg_inventory_month,
pp.safety_stock_months,
-- livello minimo di unita da mentere nel mese
round(avg(s.quantity_sales)::numeric * pp.safety_stock_months::numeric,2) as min_level_per_month

from sales_test_2025 as s 

left JOIN inventory_test_2025 as I ON
I.productid = s.productid
and I.date = s.date
 
left JOIN product_parameter as pp On
pp.productid = s.productid  

group by s.productid, s.date, pp.safety_stock_months
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



