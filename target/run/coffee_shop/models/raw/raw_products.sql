
  
  create view "coffee_shop"."main"."raw_products__dbt_tmp" as (
    select *
from "coffee_shop"."main"."products"
  );
