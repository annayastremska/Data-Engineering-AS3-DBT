
  
  create view "coffee_shop"."main"."raw_products_in_stock__dbt_tmp" as (
    select *
from "coffee_shop"."main"."products_in_stock"
  );
