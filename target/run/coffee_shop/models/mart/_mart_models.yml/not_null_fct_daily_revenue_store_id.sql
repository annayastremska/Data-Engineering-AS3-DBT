
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select store_id
from "coffee_shop"."main"."fct_daily_revenue"
where store_id is null



  
  
      
    ) dbt_internal_test