# Design decisions and tradeoffs

## Architecture
Postgres source, CSV vendor drop and a currency API are loaded by Airflow into `raw` (bronze). dbt builds `staging` and `intermediate` (silver) and `marts` (gold). Same medallion idea I used in an earlier weather project, on a different stack.

## Raw layer
Raw tables mirror the source and add `_loaded_at` (and `_source_file` for vendor files). No cleaning, so I can always rebuild downstream layers from raw.

## Loads are idempotent
- Orders: one-day window per run, delete the window then insert, in one transaction.
- Vendor files: truncate and load in one transaction.
- Exchange rates: upsert on (date, base, quote).
Re-running any day never creates duplicates.

## Grain and keys
- `fct_order_items`: one row per item in an order.
- `fct_orders`: one row per order.
- `dim_customers` is one row per real person (`customer_unique_id`), because `customer_id` is generated per order in the source.
- `order_reviews` has no unique `review_id`. I measured it: 99,224 rows, 98,410 distinct ids, but (review_id, order_id) is unique, so that pair is the key.

## Avoiding fan-out
Items, payments and reviews are aggregated to one row per order before joining in `fct_orders`. Row counts and totals are reconciled in tests.

## Currency
Prices are converted to USD at the exchange rate of the purchase date, not today's rate. Joins to rates are left joins, and a test fails if any rate is missing.

## Incremental vs full refresh
- Incremental (delete+insert, 3-day lookback): `fct_order_items`, the largest table.
- Full refresh: dimensions and `fct_orders` (small, and they contain fields that change).
- Tradeoff: incremental rows do not see later changes outside the lookback (for example an order status changing weeks later). Mitigation: periodic full refresh.

## Tests
Built-in tests (unique, not_null, relationships, accepted_values) plus custom tests: no order delivered before purchase, and fact totals equal staging totals.