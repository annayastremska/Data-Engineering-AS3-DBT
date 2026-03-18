with source as (
    select * from {{ ref('raw_products_in_stock') }}
),

cleaned as (
    select
        store_product_id,
        store_id,
        product_id,
        cast(available_since as date)           as available_since_date,
        cast(current_date - cast(available_since as date) as integer) as days_available
    from source
    where store_product_id is not null
      and store_id is not null
      and product_id is not null
)

select * from cleaned