

with stores as (
    select * from "coffee_shop"."main"."stg_stores"
),

enriched as (
    select
        store_id,
        store_name,
        city,
        region,
        opening_date,
        opening_year,
        store_size_sq_m,

        case
            when store_size_sq_m >= 115 then 'Large'
            when store_size_sq_m >= 95  then 'Medium'
            else 'Small'
        end                                         as store_size_category,

        cast(
            date_diff('day', opening_date, current_date) / 365.0
        as decimal(5,1))                            as years_in_operation

    from stores
)

select * from enriched