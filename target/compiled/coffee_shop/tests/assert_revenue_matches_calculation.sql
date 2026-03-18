-- tests/assert_revenue_matches_calculation.sql
-- Fails if gross_revenue doesn't match unit_price * transaction_qty
-- Allows a small rounding tolerance of 0.01

select *
from "coffee_shop"."main"."fct_transactions"
where abs(gross_revenue - (unit_price * transaction_qty)) > 0.01