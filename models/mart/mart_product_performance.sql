-- Monthly product performance with category rankings
{{
    config(
        materialized='incremental',
        unique_key=['product_id', 'transaction_year', 'transaction_month'],
        on_schema_change='fail'
    )
}}

with product_sales as (
    select * from {{ ref('fct_product_sales') }}
    {{ incremental_date_filter('transaction_date') }}
),

with_windows as (
    select
        product_id,
        product_category,
        product_type,
        transaction_year,
        transaction_month,
        transaction_date,
        total_units_sold,
        total_revenue,
        avg_unit_price,
        avg_transaction_value,
        transaction_count,

        dense_rank() over (
            partition by product_category, transaction_year, transaction_month
            order by total_revenue desc
        )                                       as revenue_rank_in_category,

        dense_rank() over (
            partition by transaction_year, transaction_month
            order by total_revenue desc
        )                                       as overall_revenue_rank,

        sum(total_revenue) over (
            partition by product_id
            order by transaction_year, transaction_month
            rows between unbounded preceding and current row
        )                                       as cumulative_revenue,

        lag(total_units_sold) over (
            partition by product_id
            order by transaction_year, transaction_month
        )                                       as prev_month_units

    from product_sales
),

final as (
    select
        *,
        round(
            (total_units_sold - prev_month_units)
            / nullif(prev_month_units, 0) * 100
        , 2)                                    as units_growth_pct

    from with_windows
)

select * from final