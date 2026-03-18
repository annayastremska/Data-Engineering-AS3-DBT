
  
    
    

    create  table
      "coffee_shop"."main"."mart_store_performance__dbt_tmp"
  
    as (
      -- Monthly store performance with revenue rankings and growth rates.


with daily as (
    select
        store_id,
        store_location,
        transaction_date,
        transaction_year,
        transaction_month,
        transaction_count,
        total_units_sold,
        total_revenue,
        avg_transaction_value
    from "coffee_shop"."main"."fct_daily_revenue"
    
    

),

monthly as (
    select
        store_id,
        store_location,
        transaction_year,
        transaction_month,

        sum(transaction_count)                  as monthly_transactions,
        sum(total_units_sold)                   as monthly_units_sold,
        round(sum(total_revenue), 2)            as monthly_revenue,
        round(avg(avg_transaction_value), 2)    as avg_order_value,
        count(distinct transaction_date)        as active_days

    from daily
    group by
        store_id,
        store_location,
        transaction_year,
        transaction_month
),

with_windows as (
    select
        *,

        -- rank stores by revenue within each month
        rank() over (
            partition by transaction_year, transaction_month
            order by monthly_revenue desc
        )                                       as revenue_rank_in_month,

        -- running cumulative revenue per store
        sum(monthly_revenue) over (
            partition by store_id
            order by transaction_year, transaction_month
            rows between unbounded preceding and current row
        )                                       as cumulative_revenue,

        -- previous month revenue for growth calculation
        lag(monthly_revenue) over (
            partition by store_id
            order by transaction_year, transaction_month
        )                                       as prev_month_revenue

    from monthly
),

final as (
    select
        *,
        round(
            (monthly_revenue - prev_month_revenue)
            / nullif(prev_month_revenue, 0) * 100
        , 2)                                    as revenue_growth_pct

    from with_windows
)

select * from final
    );
  
  
  