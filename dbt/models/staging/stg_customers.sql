with source as (

    select * from {{ source('raw', 'customers') }}

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by customer_id
            order by _loaded_at desc
        ) as row_num
    from source

)

select
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix as zip_code_prefix,
    customer_city            as city,
    customer_state           as state,
    _loaded_at
from deduplicated
where row_num = 1