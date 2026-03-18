
  
  create view "coffee_shop"."main"."raw_coffee_shop_transactions__dbt_tmp" as (
    select *
from "coffee_shop"."main"."coffee_shop_transactions"
  );
