/* Detailed list of cases at risk of expiry — 2025
For which products and in which specific months does inventory exceed 
the quantity that can be sold within the shelf life?
*/



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

select *
from shelf_life_risk_level
where shelf_life = 'high_risk'
order by shelf_life_qsales desc 

-- quante volte compare il prodotto a rischio scadenza? 2025

WITH safety_level AS (

SELECT 
extract(year from s.date) as year,
s.productid,
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

select 
year,
productid,
count(*) as count_high_risk_months
from shelf_life_risk_level
where shelf_life = 'high_risk' and year = 2025
group by productid, year
order by count_high_risk_months desc


-- Prodotti a rischio scadenza comuni a 2023, 2024 e 2025
WITH safety_level AS (

	SELECT
		extract(year FROM s.date) AS year,
		s.productid,
		round(avg(s.quantity_sales)::numeric, 2) AS avg_quantity_sales,
		round(avg(i.inventory_level)::numeric, 2) AS avg_inventory_month,
		pp.shelf_life_months,
		round(avg(s.quantity_sales * pp.shelf_life_months)::numeric, 2) AS shelf_life_qsales
	FROM sales_2023_2024 AS s
	JOIN inventory_2023_2024 AS i
		ON i.productid = s.productid
	   AND i.date = s.date
	JOIN product_parameter AS pp
		ON pp.productid = s.productid
	GROUP BY extract(year FROM s.date), s.productid, s.date,
			 i.inventory_level, pp.shelf_life_months

	UNION ALL

	SELECT
		extract(year FROM s.date) AS year,
		s.productid,
		round(avg(s.quantity_sales)::numeric, 2) AS avg_quantity_sales,
		round(avg(i.inventory_level)::numeric, 2) AS avg_inventory_month,
		pp.shelf_life_months,
		round(avg(s.quantity_sales * pp.shelf_life_months)::numeric, 2) AS shelf_life_qsales
	FROM sales_test_2025 AS s
	JOIN inventory_test_2025 AS i
		ON i.productid = s.productid
	   AND i.date = s.date
	JOIN product_parameter AS pp
		ON pp.productid = s.productid
	GROUP BY extract(year FROM s.date), s.productid, s.date,
			 i.inventory_level, pp.shelf_life_months
),

shelf_life_risk_level AS (
	SELECT
		*,
		CASE
			WHEN avg_inventory_month > shelf_life_qsales THEN 'high_risk'
			WHEN avg_inventory_month < shelf_life_qsales THEN 'low_risk'
			ELSE 'avg_level'
		END AS shelf_life
	FROM safety_level
)

(
    SELECT productid FROM shelf_life_risk_level WHERE shelf_life = 'high_risk' AND year = 2023
    UNION
    SELECT productid FROM shelf_life_risk_level WHERE shelf_life = 'high_risk' AND year = 2024
)
INTERSECT

SELECT productid
FROM shelf_life_risk_level
WHERE shelf_life = 'high_risk' AND year = 2025

ORDER BY productid;


