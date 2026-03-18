{{
    config(
        materialized='incremental',
        unique_key='transaction_id',
        on_schema_change='fail'
    )
}}

with transactions as (
    select * from {{ ref('stg_coffee_shop_transactions') }}
    {{ incremental_date_filter('transaction_date') }}
),

products as (
    select
        product_id,
        product_name,
        category,
        subcategory,
        product_group,
        price_tier
    from {{ ref('dim_products') }}
),

joined as (
    select
        t.transaction_id,
        t.transaction_date,
        t.transaction_time,
        t.transaction_year,
        t.transaction_month,
        t.day_of_week,
        t.store_id,
        t.store_location,
        t.product_id,
        t.product_category,
        t.product_type,
        t.product_detail,
        t.transaction_qty,
        t.unit_price,
        t.gross_revenue,

        -- peak period classification via macro
        {{ is_peak_hour('t.transaction_time') }}    as peak_period,

        p.product_name,
        p.category          as catalog_category,
        p.subcategory       as catalog_subcategory,
        p.product_group,
        p.price_tier

    from transactions t
    left join products p
        on t.product_id = p.product_id
)

select * from joined
