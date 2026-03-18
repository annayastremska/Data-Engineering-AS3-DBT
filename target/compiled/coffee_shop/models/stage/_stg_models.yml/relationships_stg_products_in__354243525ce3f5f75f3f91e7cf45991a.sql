
    
    

with child as (
    select product_id as from_field
    from "coffee_shop"."main"."stg_products_in_stock"
    where product_id is not null
),

parent as (
    select product_id as to_field
    from "coffee_shop"."main"."stg_products"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


