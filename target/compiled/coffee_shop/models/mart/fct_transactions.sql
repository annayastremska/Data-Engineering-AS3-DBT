

with transactions as (
    select * from "coffee_shop"."main"."stg_coffee_shop_transactions"
    
    

),

products as (
    select
        product_id,
        product_name,
        category,
        subcategory,
        product_group,
        price_tier
    from "coffee_shop"."main"."dim_products"
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
        
    case
        when date_part('hour', t.transaction_time) between 7 and 9   then 'Morning Peak'
        when date_part('hour', t.transaction_time) between 12 and 14  then 'Lunch Peak'
        when date_part('hour', t.transaction_time) between 17 and 19  then 'Evening Peak'
        else 'Off-Peak'
    end
    as peak_period,

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