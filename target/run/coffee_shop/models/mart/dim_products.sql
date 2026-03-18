
  
    
    

    create  table
      "coffee_shop"."main"."dim_products__dbt_tmp"
  
    as (
      

with products as (
    select * from "coffee_shop"."main"."stg_products"
),

enriched as (
    select
        product_id,
        product_name,
        category,
        subcategory,
        product_group,
        unit_price_usd,

        case
            when unit_price_usd >= 5.00 then 'Premium'
            when unit_price_usd >= 3.00 then 'Standard'
            else 'Budget'
        end                             as price_tier

    from products
)

select * from enriched
    );
  
  