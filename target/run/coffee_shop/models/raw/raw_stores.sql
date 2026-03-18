
  
  create view "coffee_shop"."main"."raw_stores__dbt_tmp" as (
    select *
from "coffee_shop"."main"."stores"
  );
