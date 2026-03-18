
    
    

with all_values as (

    select
        gender as value_field,
        count(*) as n_records

    from "coffee_shop"."main"."stg_customers"
    group by gender

)

select *
from all_values
where value_field not in (
    'F','M'
)


