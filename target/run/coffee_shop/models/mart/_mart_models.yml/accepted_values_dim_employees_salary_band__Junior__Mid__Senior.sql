
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        salary_band as value_field,
        count(*) as n_records

    from "coffee_shop"."main"."dim_employees"
    group by salary_band

)

select *
from all_values
where value_field not in (
    'Junior','Mid','Senior'
)



  
  
      
    ) dbt_internal_test