with source as (

    select * from {{ source('raw', 'sellers') }}

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by seller_id
            order by _loaded_at desc
        ) as row_num
    from source

)

select
    seller_id,
    seller_zip_code_prefix as zip_code_prefix,
    seller_city            as city,
    seller_state           as state,
    _loaded_at
from deduplicated
where row_num = 1