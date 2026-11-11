with source as (

    select * from {{ source('raw', 'products') }}

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by product_id
            order by _loaded_at desc
        ) as row_num
    from source

)

select
    product_id,
    product_category_name  as category_name_pt,
    product_name_lenght    as name_length,
    product_description_lenght as description_length,
    product_photos_qty     as photos_qty,
    product_weight_g       as weight_g,
    product_length_cm      as length_cm,
    product_height_cm      as height_cm,
    product_width_cm       as width_cm,
    _loaded_at
from deduplicated
where row_num = 1