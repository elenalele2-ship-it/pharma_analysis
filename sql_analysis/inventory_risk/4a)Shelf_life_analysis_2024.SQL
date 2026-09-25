/* Detailed list of cases at risk of expiry — 2024
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

select *
from shelf_life_risk_level
where shelf_life = 'high_risk'
order by shelf_life_qsales desc 


-- quante volte compare il prodotto a rischio scadenza? 2023

WITH safety_level AS (

SELECT 
extract(year from s.date) as year,
s.productid,
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

select 
year,
productid,
count(*) as count_high_risk_months
from shelf_life_risk_level
where shelf_life = 'high_risk' and year = 2023
group by productid, year
order by count_high_risk_months desc

-- quante volte compare il prodotto a rischio scadenza? 2024

WITH safety_level AS (

SELECT 
extract(year from s.date) as year,
s.productid,
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

select 
year,
productid,
count(*) as count_high_risk_months
from shelf_life_risk_level
where shelf_life = 'high_risk' and year = 2024
group by productid, year
order by count_high_risk_months desc


-- Intersechiamo per cercare i prodotti comuni ad entrambi gli anni,
WITH safety_level AS (

SELECT 
extract(year from s.date) as year,
s.productid,
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

select 
productid
from shelf_life_risk_level
where shelf_life = 'high_risk' and year = 2023

intersect

select
productid
from shelf_life_risk_level
where shelf_life = 'high_risk' and year = 2024