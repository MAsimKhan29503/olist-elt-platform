with items as (

    select * from {{ ref('int_order_items_usd') }}

),

customers as (

    select
        customer_id,
        customer_unique_id
    from {{ ref('stg_customers') }}

)

select
    items.order_item_key,
    items.order_id,
    items.order_item_id,
    customers.customer_unique_id                      as customer_key,
    items.product_id                                  as product_key,
    items.seller_id                                   as seller_key,
    items.purchase_date,
    items.purchased_at,
    items.order_status,
    items.item_price_brl,
    items.freight_value_brl,
    items.brl_to_usd_rate,
    items.item_price_usd,
    items.freight_value_usd,
    items.item_price_usd + items.freight_value_usd    as total_value_usd
from items
left join customers
    on items.customer_id = customers.customer_id