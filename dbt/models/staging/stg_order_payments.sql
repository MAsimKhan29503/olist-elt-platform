with source as (

    select * from {{ source('raw', 'order_payments') }}

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by order_id, payment_sequential
            order by _loaded_at desc
        ) as row_num
    from source

)

select
    order_id || '-' || payment_sequential::text as payment_key,
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value as payment_value_brl,
    _loaded_at
from deduplicated
where row_num = 1