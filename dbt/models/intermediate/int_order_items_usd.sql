with items as (

    select * from {{ ref('stg_order_items') }}

),

orders as (

    select
        order_id,
        customer_id,
        order_status,
        purchased_at
    from {{ ref('stg_orders') }}

),

rates as (

    select
        rate_date,
        exchange_rate
    from {{ ref('stg_fx_rates') }}
    where base_currency = 'BRL'
      and quote_currency = 'USD'

)

select
    items.order_item_key,
    items.order_id,
    items.order_item_id,
    items.product_id,
    items.seller_id,
    orders.customer_id,
    orders.order_status,
    orders.purchased_at,
    orders.purchased_at::date                                    as purchase_date,
    items.item_price_brl,
    items.freight_value_brl,
    rates.exchange_rate                                          as brl_to_usd_rate,
    round(items.item_price_brl * rates.exchange_rate, 2)         as item_price_usd,
    round(items.freight_value_brl * rates.exchange_rate, 2)      as freight_value_usd
from items
inner join orders
    on items.order_id = orders.order_id
left join rates
    on orders.purchased_at::date = rates.rate_date