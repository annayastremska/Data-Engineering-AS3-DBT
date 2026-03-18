
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select unit_price
from "coffee_shop"."main"."stg_coffee_shop_transactions"
where unit_price is null



  
  
      
    ) dbt_internal_test