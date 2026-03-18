
  
  create view "coffee_shop"."main"."stg_customers__dbt_tmp" as (
    with source as (
    select * from "coffee_shop"."main"."raw_customers"
),

cleaned as (
    select
        customer_id,
        trim(lower(first_name))             as first_name,
        trim(lower(last_name))              as last_name,
        upper(gender)                       as gender,        
        cast(signup_date as date)           as signup_date,
        trim(city)                 as city,
        date_part('year', cast(signup_date as date))  as signup_year,
        date_part('month', cast(signup_date as date)) as signup_month
    from source
    where customer_id is not null
)

select * from cleaned
  );
