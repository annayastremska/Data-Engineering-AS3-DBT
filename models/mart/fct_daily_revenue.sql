{{
    config(
        materialized='incremental',
        unique_key=['store_id', 'transaction_date'],
        on_schema_change='fail'
    )
}}

with transactions as (
    select
        transaction_date,
        transaction_month,
        transaction_year,
        store_id,
        store_location,
        transaction_qty,
        gross_revenue
    from {{ ref('stg_coffee_shop_transactions') }}
    {{ incremental_date_filter('transaction_date') }}
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