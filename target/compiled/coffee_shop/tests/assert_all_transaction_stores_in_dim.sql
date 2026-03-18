-- tests/assert_all_transaction_stores_in_dim.sql
-- Fails if a store_id appears in fct_transactions but not in dim_stores.
-- Catches data integrity issues where transactions reference unknown stores.

select distinct t.store_id
from "coffee_shop"."main"."fct_transactions" t
left join "coffee_shop"."main"."dim_stores" s
    on t.store_id = s.store_id
where s.store_id is null