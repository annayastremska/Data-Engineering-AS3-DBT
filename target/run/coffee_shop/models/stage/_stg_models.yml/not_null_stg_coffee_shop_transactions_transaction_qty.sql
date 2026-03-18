
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select transaction_qty
from "coffee_shop"."main"."stg_coffee_shop_transactions"
where transaction_qty is null



  
  
      
    ) dbt_internal_test