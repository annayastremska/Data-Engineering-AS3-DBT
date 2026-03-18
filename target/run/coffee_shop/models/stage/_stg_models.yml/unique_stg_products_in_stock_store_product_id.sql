
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    store_product_id as unique_field,
    count(*) as n_records

from "coffee_shop"."main"."stg_products_in_stock"
where store_product_id is not null
group by store_product_id
having count(*) > 1



  
  
      
    ) dbt_internal_test