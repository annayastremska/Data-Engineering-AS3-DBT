
  
    
    

    create  table
      "coffee_shop"."main"."mart_employee_store_summary__dbt_tmp"
  
    as (
      -- Employee performance summary per store.



with employees as (
    select * from "coffee_shop"."main"."dim_employees"
),

store_summary as (
    select
        store_id,
        store_name,
        city,
        region,

        count(employee_id)                          as total_headcount,
        round(sum(salary_usd), 2)                   as total_monthly_salary,
        round(avg(salary_usd), 2)                   as avg_salary,

        -- role breakdown
        count(case when role = 'Manager'    then 1 end) as manager_count,
        count(case when role = 'Supervisor' then 1 end) as supervisor_count,
        count(case when role = 'Barista'    then 1 end) as barista_count,
        count(case when role = 'Cashier'    then 1 end) as cashier_count,

        -- average tenure
        round(avg(tenure_years), 1)                 as avg_tenure_years

    from employees
    group by store_id, store_name, city, region
)

select * from store_summary
    );
  
  