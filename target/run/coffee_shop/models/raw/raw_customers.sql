
  
  create view "coffee_shop"."main"."raw_customers__dbt_tmp" as (
    select *
from "coffee_shop"."main"."customers"
  );
