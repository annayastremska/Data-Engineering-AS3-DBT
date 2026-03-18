
  
    
    

    create  table
      "coffee_shop"."main"."fct_daily_revenue__dbt_tmp"
  
    as (
      

with transactions as (
    select
        transaction_date,
        transaction_month,
        transaction_year,
        store_id,
        store_location,
        transaction_qty,
        gross_revenue
    from "coffee_shop"."main"."stg_coffee_shop_transactions"
    
    

),

daily as (
    select
        store_id,
        store_location,
        transaction_date,
        transaction_year,
        transaction_month,

        count(*)                         as transaction_count,
        sum(transaction_qty)             as total_units_sold,
        sum(gross_revenue)               as total_revenue,
        round(avg(gross_revenue), 2)     as avg_transaction_value

    from transactions
    group by
        store_id,
        store_location,
        transaction_date,
        transaction_year,
        transaction_month
)

select * from daily
    );
  
  
  