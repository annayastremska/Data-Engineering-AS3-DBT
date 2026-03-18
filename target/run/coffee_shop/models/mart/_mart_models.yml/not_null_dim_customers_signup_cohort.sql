
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select signup_cohort
from "coffee_shop"."main"."dim_customers"
where signup_cohort is null



  
  
      
    ) dbt_internal_test