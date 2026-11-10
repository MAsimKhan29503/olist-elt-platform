CREATE TABLE IF NOT EXISTS raw.fx_rates (
    rate_date      date,
    base_currency  text,
    quote_currency text,
    rate           numeric(12,6),
    _loaded_at     timestamptz DEFAULT now(),
    PRIMARY KEY (rate_date, base_currency, quote_currency)
);