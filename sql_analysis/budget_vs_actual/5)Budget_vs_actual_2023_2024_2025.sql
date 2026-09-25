/* Plan vs. Actuals (Annual Variance) - 2023 - 2024 - 2025
For each product and year, how much does the actual revenue generated differ from the planned budget?
*/



with budget_vs_actual as (

    -- 2023-2024
    select 
        s.productid,
        extract(year from s.date) as year,
        pp.price_pln_per_unit as p_unit,
        fp.units as annual_budget_units,
        sum(s.quantity_sales) as annual_quantity_units,
        fp.pln as annual_budget,
        round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,
        round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance,
        'actual' as source
    from sales_2023_2024 as s
    left join financial_plan_2023_2024 as fp 
        on fp.productid = s.productid 
        and extract(year from s.date) = extract(year from fp.date)
    left join product_parameter as pp 
        on pp.productid = s.productid
    group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln, fp.units

    union all

    -- test 2025

    select 
        s.productid,
        extract(year from s.date) as year,
        pp.price_pln_per_unit as p_unit,
        fp.units as annual_budget_units,
        sum(s.quantity_sales) as annual_quantity_units,
        fp.pln as annual_budget,
        round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,
        round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance,
        'test' as source
    from sales_test_2025 as s
    left join financial_plan_2025 as fp 
        on fp.productid = s.productid 
        and extract(year from s.date) = extract(year from fp.date)
    left join product_parameter as pp 
        on pp.productid = s.productid
    group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln, fp.units

),

budget_case as (
    select *,
        case 
            when variance > 0 then 'Over Budget'
            when variance < 0 then 'Under Budget'
            else 'On Budget'
        end as budget_status 
    from budget_vs_actual
),

units_gap as (
    select
        productid,
        year,
        p_unit,
        annual_budget_units,
        annual_quantity_units,
        annual_quantity_units - annual_budget_units as gap_units,
        variance,
        case
            when p_unit > 31.485 then 'High Price'
            when p_unit < 31.485 then 'Low Price'
            else 'Medium Price'
        end as price_category
    from budget_case
)

-- variance sum by year and price category
select  
    year,
    price_category,
    sum(variance) as total_variance 
from units_gap
group by year, price_category
order by year, price_category;      




 -- Budget vs Actual units by year / Is the 2025 variance growth driven by a lower budget, or by higher real sales?

with budget_vs_actual as (

    -- storico 2023-2024
    select 
        s.productid,
        extract(year from s.date) as year,
        pp.price_pln_per_unit as p_unit,
        fp.units as annual_budget_units,
        sum(s.quantity_sales) as annual_quantity_units,
        fp.pln as annual_budget,
        round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,
        round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance,
        'actual' as source
    from sales_2023_2024 as s
    left join financial_plan_2023_2024 as fp 
        on fp.productid = s.productid 
        and extract(year from s.date) = extract(year from fp.date)
    left join product_parameter as pp 
        on pp.productid = s.productid
    group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln, fp.units

    union all

    -- test 2025
    select 
        s.productid,
        extract(year from s.date) as year,
        pp.price_pln_per_unit as p_unit,
        fp.units as annual_budget_units,
        sum(s.quantity_sales) as annual_quantity_units,
        fp.pln as annual_budget,
        round((pp.price_pln_per_unit * sum(s.quantity_sales))::numeric, 2) as annual_revenue_actual,
        round(((pp.price_pln_per_unit * sum(s.quantity_sales)) - fp.pln)::numeric, 2) as variance,
        'test' as source
    from sales_test_2025 as s
    left join financial_plan_2025 as fp 
        on fp.productid = s.productid 
        and extract(year from s.date) = extract(year from fp.date)
    left join product_parameter as pp 
        on pp.productid = s.productid
    group by s.productid, extract(year from s.date), pp.price_pln_per_unit, fp.pln, fp.units

),

budget_case as (
    select *,
        case 
            when variance > 0 then 'Over Budget'
            when variance < 0 then 'Under Budget'
            else 'On Budget'
        end as budget_status 
    from budget_vs_actual
),

units_gap as (
    select
        productid,
        year,
        p_unit,
        annual_budget_units,
        annual_quantity_units,
        annual_quantity_units - annual_budget_units as gap_units,
        variance,
        case
            when p_unit > 31.485 then 'High Price'
            when p_unit < 31.485 then 'Low Price'
            else 'Medium Price'
        end as price_category
    from budget_case
)

-- somma di variance per anno e fascia
select
    year,
    sum(annual_budget_units) as total_budget_units,
    sum(annual_quantity_units) as total_actual_units,
    sum(annual_quantity_units) - sum(annual_budget_units) as total_gap_units
from units_gap
group by year
order by year;

 