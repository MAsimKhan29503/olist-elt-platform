with customers as (

    select
        customer_id,
        customer_unique_id,
        zip_code_prefix,
        city,
        state
    from {{ ref('stg_customers') }}

),

orders as (

    select
        order_id,
        customer_id,
        purchased_at
    from {{ ref('stg_orders') }}

),

joined as (

    select
        customers.customer_unique_id,
        customers.zip_code_prefix,
        customers.city,
        customers.state,
        orders.order_id,
        orders.purchased_at
    from customers
    left join orders
        on customers.customer_id = orders.customer_id

),

ranked as (

    select
        *,
        row_number() over (
            partition by customer_unique_id
            order by purchased_at desc nulls last
        ) as row_num,
        min(purchased_at) over (partition by customer_unique_id) as first_order_at,
        max(purchased_at) over (partition by customer_unique_id) as last_order_at,
        count(order_id)   over (partition by customer_unique_id) as orders_count
    from joined

)

select
    customer_unique_id as customer_key,
    zip_code_prefix,
    city,
    state,
    first_order_at,
    last_order_at,
    orders_count
from ranked
where row_num = 1