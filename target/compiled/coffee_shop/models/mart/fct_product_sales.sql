

with transactions as (
    select
        product_id,
        product_category,
        product_type,
        transaction_year,
        transaction_month,
        transaction_date,
        transaction_qty,
        unit_price,
        gross_revenue
    from "coffee_shop"."main"."stg_coffee_shop_transactions"
    
    

),

monthly_product as (
    select
        product_id,
        product_category,
        product_type,
        transaction_year,
        transaction_month,
        max(transaction_date) as transaction_date,

        count(*)                                as transaction_count,
        sum(transaction_qty)                    as total_units_sold,
        sum(gross_revenue)                      as total_revenue,
        round(avg(unit_price), 2)               as avg_unit_price,
        round(avg(gross_revenue), 2)            as avg_transaction_value,
        max(gross_revenue)                      as max_single_transaction

    from transactions
    group by
        product_id,
        product_category,
        product_type,
        transaction_year,
        transaction_month
)

select * from monthly_product