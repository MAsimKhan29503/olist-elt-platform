-- Fails if the item value in the fact table differs from staging.
with fact as (

    select sum(item_price_brl) as total
    from {{ ref('fct_order_items') }}

),

staging as (

    select sum(item_price_brl) as total
    from {{ ref('stg_order_items') }}

)

select
    fact.total    as fact_total_brl,
    staging.total as staging_total_brl
from fact
cross join staging
where fact.total <> staging.total