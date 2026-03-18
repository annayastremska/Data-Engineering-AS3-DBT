
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select store_id
from "coffee_shop"."main"."mart_hourly_patterns"
where store_id is null



  
  
      
    ) dbt_internal_test