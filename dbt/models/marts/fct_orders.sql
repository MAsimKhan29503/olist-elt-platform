with orders as (

    select * from {{ ref('stg_orders') }}

),

customers as (

    select
        customer_id,
        customer_unique_id
    from {{ ref('stg_customers') }}

),

items as (

    select
        order_id,
        count(*)               as items_count,
        sum(item_price_brl)    as items_value_brl,
        sum(freight_value_brl) as freight_value_brl,
        sum(item_price_usd)    as items_value_usd,
        sum(freight_value_usd) as freight_value_usd
    from {{ ref('int_order_items_usd') }}
    group by order_id

),

payments as (

    select
        order_id,
        count(*)               as payments_count,
        sum(payment_value_brl) as payment_value_brl
    from {{ ref('stg_order_payments') }}
    group by order_id

),

reviews as (

    select
        order_id,
        count(*)                         as reviews_count,
        round(avg(review_score), 2)      as avg_review_score
    from {{ ref('stg_order_reviews') }}
    group by order_id

)

select
    orders.order_id,
    customers.customer_unique_id                 as customer_key,
    orders.order_status,
    orders.purchased_at,
    orders.purchased_at::date                    as purchase_date,
    orders.approved_at,
    orders.shipped_at,
    orders.delivered_at,
    orders.estimated_delivery_at,
    coalesce(items.items_count, 0)               as items_count,
    items.items_value_brl,
    items.freight_value_brl,
    items.items_value_usd,
    items.freight_value_usd,
    payments.payment_value_brl,
    reviews.avg_review_score,
    case
        when orders.delivered_at is not null
        then orders.delivered_at::date - orders.purchased_at::date
    end                                          as days_to_deliver,
    case
        when orders.delivered_at is not null
        then orders.delivered_at > orders.estimated_delivery_at
    end                                          as is_delivered_late
from orders
left join customers on orders.customer_id = customers.customer_id
left join items     on orders.order_id    = items.order_id
left join payments  on orders.order_id    = payments.order_id
left join reviews   on orders.order_id    = reviews.order_id