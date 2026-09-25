/* 
Product Risk stockout lead time. 2023-2024
Cross-analysis with lead time.
Products at risk of stockout with lead time.
Cross-analysis: safety stock policy vs. lead time coverage
"How are cases distributed across the different combinations of risk (safety stock) and coverage (lead time)?"
*/



WITH monthly_metrics AS (

SELECT 
s.productid,
s.date,
round(avg(s.quantity_sales)::numeric,2) as avg_quantity_sales,
round(avg(I.inventory_level)::numeric,2) as avg_inventory_month,
pp.safety_stock_months,
pp.lead_time_months,
round(avg(quantity_sales*pp.lead_time_months)::numeric,2) as lead_time_sales,


-- livello minimo di unita da mentere nel mese
round(avg(s.quantity_sales)::numeric * pp.safety_stock_months::numeric,2) as Min_level_per_month

FROM sales_2023_2024 as s

JOIN inventory_2023_2024 as I ON
I.productid = s.productid
and I.date = s.date

JOIN product_parameter as pp On
pp.productid = s.productid

group by s.productid, pp.safety_stock_months, pp.lead_time_months, s.date
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
FROM monthly_metrics
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
safety_level,
lead_time_coverage_status,
count(*) as case_nmb 
from lead_time_risk
group by safety_level, lead_time_coverage_status
order by safety_level desc





