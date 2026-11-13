select
    seller_id as seller_key,
    zip_code_prefix,
    city,
    state
from {{ ref('stg_sellers') }}