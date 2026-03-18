
  
    
    

    create  table
      "coffee_shop"."main"."dim_customers__dbt_tmp"
  
    as (
      

with customers as (
    select * from "coffee_shop"."main"."stg_customers"
),

enriched as (
    select
        customer_id,
        first_name,
        last_name,
        first_name || ' ' || last_name          as full_name,
        gender,
        city,
        signup_date,
        signup_year,
        signup_month,

        -- '2023-Q1'
        signup_year || '-Q' ||
            cast(ceil(signup_month / 3.0) as integer)   as signup_cohort
    
    from customers
)

select * from enriched
    );
  
  