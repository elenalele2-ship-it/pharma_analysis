/* Products furthest under budget (negative variance)
"Which products, by year, deviated the most negatively from the planned budget?" */

-- 2025

select 
    s.productid,
    extract(year from s.date) as year,
    pp.price_pln_per_unit as p_unit,

    sum(s.quantity_sales) as annual_quantity,
        fp.pln as annual_budget,

    round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,

    round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance

 
from sales_test_2025 as s

left join financial_plan_2025 as fp on
    fp.productid = s.productid and
    extract(year from s.date) = extract(year from fp.date)
left join product_parameter as pp on
    pp.productid = s.productid

group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln
order by variance, annual_quantity asc
limit 10


/* Products furthest over budget (positive variance)
"Which products, by year, exceeded budget expectations the most?" */

select 
    s.productid,
    extract(year from s.date) as year,
    pp.price_pln_per_unit as p_unit,

    sum(s.quantity_sales) as annual_quantity,
        fp.pln as annual_budget,

    round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,

    round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance


from sales_test_2025 as s

left join financial_plan_2025 as fp on
    fp.productid = s.productid and
    extract(year from s.date) = extract(year from fp.date)
left join product_parameter as pp on
    pp.productid = s.productid

group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln
order by variance desc 
limit 10


-- 2024
--Products furthest under budget (negative variance)

select 
    s.productid,
    extract(year from s.date) as year,
    pp.price_pln_per_unit as p_unit,

    sum(s.quantity_sales) as annual_quantity,
        fp.pln as annual_budget,

    round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,

    round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance

 
from sales_2023_2024 as s

left join financial_plan_2023_2024 as fp on
    fp.productid = s.productid and
    extract(year from s.date) = extract(year from fp.date)
left join product_parameter as pp on
    pp.productid = s.productid

where extract(year from s.date) = 2024
group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln
order by variance, annual_quantity asc
limit 10

-- Products furthest over budget (positive variance)
select 
    s.productid,
    extract(year from s.date) as year,
    pp.price_pln_per_unit as p_unit,

    sum(s.quantity_sales) as annual_quantity,
        fp.pln as annual_budget,

    round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,

    round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance


from sales_2023_2024 as s

left join financial_plan_2023_2024 as fp on
    fp.productid = s.productid and
    extract(year from s.date) = extract(year from fp.date)
left join product_parameter as pp on
    pp.productid = s.productid

where extract(year from s.date) = 2024
group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln
order by variance desc 
limit 10

2023

select 
    s.productid,
    extract(year from s.date) as year,
    pp.price_pln_per_unit as p_unit,

    sum(s.quantity_sales) as annual_quantity,
        fp.pln as annual_budget,

    round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,

    round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance

 
from sales_2023_2024 as s

left join financial_plan_2023_2024 as fp on
    fp.productid = s.productid and
    extract(year from s.date) = extract(year from fp.date)
left join product_parameter as pp on
    pp.productid = s.productid

where extract(year from s.date) = 2023
group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln
order by variance, annual_quantity asc
limit 10

-- Products furthest over budget (positive variance)
select 
    s.productid,
    extract(year from s.date) as year,
    pp.price_pln_per_unit as p_unit,

    sum(s.quantity_sales) as annual_quantity,
        fp.pln as annual_budget,

    round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,

    round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance


from sales_2023_2024 as s

left join financial_plan_2023_2024 as fp on
    fp.productid = s.productid and
    extract(year from s.date) = extract(year from fp.date)
left join product_parameter as pp on
    pp.productid = s.productid

where extract(year from s.date) = 2023
group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln
order by variance desc 
limit 10

