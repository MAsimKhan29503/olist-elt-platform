select
    rate_date,
    base_currency,
    quote_currency,
    rate as exchange_rate,
    _loaded_at
from {{ source('raw', 'fx_rates') }}