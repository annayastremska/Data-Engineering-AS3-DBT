
    
    

with all_values as (

    select
        price_tier as value_field,
        count(*) as n_records

    from "coffee_shop"."main"."dim_products"
    group by price_tier

)

select *
from all_values
where value_field not in (
    'Budget','Standard','Premium'
)


