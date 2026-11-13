with products as (

    select * from {{ ref('stg_products') }}

),

translation as (

    select
        product_category_name,
        product_category_name_english
    from {{ ref('product_category_translation') }}

)

select
    products.product_id                                   as product_key,
    products.category_name_pt,
    coalesce(
        translation.product_category_name_english,
        products.category_name_pt,
        'unknown'
    )                                                     as category_name_en,
    products.photos_qty,
    products.weight_g,
    products.length_cm,
    products.height_cm,
    products.width_cm
from products
left join translation
    on products.category_name_pt = translation.product_category_name