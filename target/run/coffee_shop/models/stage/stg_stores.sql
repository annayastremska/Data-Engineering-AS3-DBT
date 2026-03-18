
  
  create view "coffee_shop"."main"."stg_stores__dbt_tmp" as (
    with source as (
    select * from "coffee_shop"."main"."raw_stores"
),

cleaned as (
    select
        store_id,
        trim(store_name)                        as store_name,
        trim(city)                     as city,
        trim(upper(region))                     as region,
        cast(opening_date as date)              as opening_date,
        cast(store_size_sq_m as integer)        as store_size_sq_m,
        date_part('year', cast(opening_date as date)) as opening_year
    from source
    where store_id is not null
)

select * from cleaned
  );
