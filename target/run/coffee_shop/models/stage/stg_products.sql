
  
  create view "coffee_shop"."main"."stg_products__dbt_tmp" as (
    with source as (
    select * from "coffee_shop"."main"."raw_products"
),

cleaned as (
    select
        product_id,
        trim(product_name)                      as product_name,
        trim(category)                 as category,       
        trim(subcategory)              as subcategory,   
        cast(unit_price as decimal(10, 2))      as unit_price_usd,
        case
            when lower(subcategory) in ('hot', 'cold') then 'Beverage'
            else 'Food'
        end                                     as product_group
    from source
    where product_id is not null
)

select * from cleaned
  );
