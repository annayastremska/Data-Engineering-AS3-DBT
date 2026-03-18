
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        store_size_category as value_field,
        count(*) as n_records

    from "coffee_shop"."main"."dim_stores"
    group by store_size_category

)

select *
from all_values
where value_field not in (
    'Small','Medium','Large'
)



  
  
      
    ) dbt_internal_test