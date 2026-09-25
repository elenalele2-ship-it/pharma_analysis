/*  2025
Critical stockout risk — highest severity cases
Products at risk of stockout by lead time.
Detailed, ranked list of critical-risk cases.
"Which specific products and months are already outside the safety stock policy 
AND do not have enough inventory to cover the full lead-time period — 
the highest-severity cases requiring immediate action?"
*/



WITH safety_level AS (

SELECT 
s.productid,
s.date,
round(avg(s.quantity_sales)::numeric,2) as avg_quantity_sales,
round(avg(I.inventory_level)::numeric,2) as avg_inventory_month,
pp.safety_stock_months,
pp.lead_time_months,
round(avg(quantity_sales*pp.lead_time_months)::numeric,2) as lead_time_sales,

-- gap avg inventory - lead time sales
round(avg(I.inventory_level)::numeric - round(avg(quantity_sales*pp.lead_time_months)::numeric,2),2) as gap_inventory_lead_time_sales,

-- Min level of units to maintain in the month
round(avg(s.quantity_sales)::numeric * pp.safety_stock_months::numeric,2) as Min_level_per_month

FROM sales_test_2025 as s

JOIN inventory_test_2025 as I ON
I.productid = s.productid
and I.date = s.date

JOIN product_parameter as pp On
pp.productid = s.productid

group by s.productid, s.date, I.inventory_level, pp.safety_stock_months, pp.lead_time_months
order by s.productid, s.date
),


case_level AS (
SELECT
*,
case
when Min_level_per_month < avg_inventory_month then 'adequate_stock'
when Min_level_per_month > avg_inventory_month then 'stockout_risk'
else 'avg_level'
end as level_stock
FROM safety_level
),


lead_time_risk AS (
SELECT
*,
case
when avg_inventory_month < lead_time_sales then 'insufficient_coverage' 
when avg_inventory_month > lead_time_sales then 'sufficient_coverage'
else 'avg_level'
end as lead_time_coverage_status
from case_level
)

select 
productid, 
date,
lead_time_sales,
avg_inventory_month,
level_stock,
lead_time_coverage_status,
gap_inventory_lead_time_sales
from lead_time_risk
where level_stock = 'stockout_risk' and lead_time_coverage_status = 'insufficient_coverage'
order by gap_inventory_lead_time_sales asc