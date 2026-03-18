
  
  create view "coffee_shop"."main"."raw_employees__dbt_tmp" as (
    select *
from "coffee_shop"."main"."employees"
  );
