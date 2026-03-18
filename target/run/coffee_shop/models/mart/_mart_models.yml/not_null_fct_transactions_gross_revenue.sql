
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select gross_revenue
from "coffee_shop"."main"."fct_transactions"
where gross_revenue is null



  
  
      
    ) dbt_internal_test