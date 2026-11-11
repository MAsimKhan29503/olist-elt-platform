with source as (

    select * from {{ source('raw', 'order_reviews') }}

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by review_id, order_id
            order by _loaded_at desc
        ) as row_num
    from source

)

select
    review_id || '-' || order_id as review_key,
    review_id,
    order_id,
    review_score,
    review_comment_title         as comment_title,
    review_comment_message       as comment_message,
    review_creation_date         as review_created_at,
    review_answer_timestamp      as review_answered_at,
    _loaded_at
from deduplicated
where row_num = 1