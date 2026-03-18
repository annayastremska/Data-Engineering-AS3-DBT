
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        product_group as value_field,
        count(*) as n_records

    from "coffee_shop"."main"."stg_products"
    group by product_group

)

select *
from all_values
where value_field not in (
    'Beverage','Food'
)



  
  
      
    ) dbt_internal_test