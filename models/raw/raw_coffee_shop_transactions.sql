select *
from {{ source('coffee_shop_raw', 'coffee_shop_transactions') }}