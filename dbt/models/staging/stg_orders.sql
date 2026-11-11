with source as (

    select * from {{ source('raw', 'orders') }}

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by order_id
            order by _loaded_at desc
        ) as row_num
    from source

)

select
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp      as purchased_at,
    order_approved_at             as approved_at,
    order_delivered_carrier_date  as shipped_at,
    order_delivered_customer_date as delivered_at,
    order_estimated_delivery_date as estimated_delivery_at,
    _loaded_at
from deduplicated
where row_num = 1