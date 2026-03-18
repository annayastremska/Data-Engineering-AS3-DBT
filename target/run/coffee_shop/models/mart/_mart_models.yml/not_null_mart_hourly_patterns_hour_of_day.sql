
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select hour_of_day
from "coffee_shop"."main"."mart_hourly_patterns"
where hour_of_day is null



  
  
      
    ) dbt_internal_test