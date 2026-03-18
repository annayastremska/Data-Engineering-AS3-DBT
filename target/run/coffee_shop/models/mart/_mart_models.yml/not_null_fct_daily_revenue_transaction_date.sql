
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select transaction_date
from "coffee_shop"."main"."fct_daily_revenue"
where transaction_date is null



  
  
      
    ) dbt_internal_test