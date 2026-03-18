select *
from {{ source('coffee_shop_raw', 'products_in_stock') }}