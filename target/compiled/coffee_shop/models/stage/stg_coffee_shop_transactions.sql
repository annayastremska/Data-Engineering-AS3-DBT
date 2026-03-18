with source as (
    select * from "coffee_shop"."main"."raw_coffee_shop_transactions"
),

cleaned as (
    select
        cast(transaction_id as integer)                             as transaction_id,

        strptime(transaction_date, '%-m/%-d/%Y')::date              as transaction_date,
        cast(transaction_time as time)                              as transaction_time,

        cast(transaction_qty as integer)                            as transaction_qty,

        cast(store_id as integer)                                   as store_id,
        trim(store_location)                                        as store_location,

        cast(product_id as integer)                                 as product_id,

        -- fixinf comma-as-decimal issue
        cast(
            replace(cast(unit_price as varchar), ',', '.')
        as decimal(10, 2))                                          as unit_price,

        trim(product_category)                           as product_category,
        trim(product_type)                                 as product_type,
        trim(product_detail)                                        as product_detail,

        cast(
            replace(cast(unit_price as varchar), ',', '.')
        as decimal(10, 2))
        * cast(transaction_qty as integer)                          as gross_revenue,

        date_part('year',  strptime(transaction_date, '%-m/%-d/%Y')::date) as transaction_year,
        date_part('month', strptime(transaction_date, '%-m/%-d/%Y')::date) as transaction_month,
        date_part('dow',   strptime(transaction_date, '%-m/%-d/%Y')::date) as day_of_week    

    from source
    where transaction_id is not null
      and transaction_qty > 0
)

select * from cleaned