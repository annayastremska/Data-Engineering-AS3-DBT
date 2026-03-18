
  
    
    

    create  table
      "coffee_shop"."main"."mart_hourly_patterns__dbt_tmp"
  
    as (
      -- Hourly sales pattern analysis per store.


with transactions as (
    select
        transaction_time,
        gross_revenue,
        transaction_qty,
        store_id
    from "coffee_shop"."main"."stg_coffee_shop_transactions"
),

with_hour as (
    select
        store_id,
        date_part('hour', transaction_time)         as hour_of_day,
        -- peak period via macro
        
    case
        when date_part('hour', transaction_time) between 7 and 9   then 'Morning Peak'
        when date_part('hour', transaction_time) between 12 and 14  then 'Lunch Peak'
        when date_part('hour', transaction_time) between 17 and 19  then 'Evening Peak'
        else 'Off-Peak'
    end
      as peak_period,
        gross_revenue,
        transaction_qty
    from transactions
),

hourly as (
    select
        store_id,
        hour_of_day,
        peak_period,
        count(*)                                    as transaction_count,
        sum(transaction_qty)                        as units_sold,
        round(sum(gross_revenue), 2)                as total_revenue

    from with_hour
    group by store_id, hour_of_day, peak_period
),

with_windows as (
    select
        store_id,
        hour_of_day,
        peak_period,
        transaction_count,
        units_sold,
        total_revenue,

        -- rank hours by revenue within each store
        rank() over (
            partition by store_id
            order by total_revenue desc
        )                                           as revenue_rank,

        -- each hour's share of total store revenue
        round(
            total_revenue
            / sum(total_revenue) over (partition by store_id) * 100
        , 2)                                        as pct_of_store_revenue

    from hourly
)

select * from with_windows
order by store_id, hour_of_day
    );
  
  