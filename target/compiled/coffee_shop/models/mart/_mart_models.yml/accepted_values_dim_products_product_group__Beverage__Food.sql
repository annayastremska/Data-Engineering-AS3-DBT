
    
    

with all_values as (

    select
        product_group as value_field,
        count(*) as n_records

    from "coffee_shop"."main"."dim_products"
    group by product_group

)

select *
from all_values
where value_field not in (
    'Beverage','Food'
)


