with source as (

    select * from {{ source('raw', 'order_items') }}

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by order_id, order_item_id
            order by _loaded_at desc
        ) as row_num
    from source

)

select
    order_id || '-' || order_item_id::text as order_item_key,
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date as shipping_limit_at,
    price               as item_price_brl,
    freight_value       as freight_value_brl,
    _loaded_at
from deduplicated
where row_num = 1