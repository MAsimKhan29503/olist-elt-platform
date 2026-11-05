\copy customers      FROM '/data/olist/olist_customers_dataset.csv'      WITH (FORMAT csv, HEADER true)
\copy orders         FROM '/data/olist/olist_orders_dataset.csv'         WITH (FORMAT csv, HEADER true)
\copy order_items    FROM '/data/olist/olist_order_items_dataset.csv'    WITH (FORMAT csv, HEADER true)
\copy order_payments FROM '/data/olist/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true)
\copy order_reviews  FROM '/data/olist/olist_order_reviews_dataset.csv'  WITH (FORMAT csv, HEADER true)

CREATE INDEX idx_orders_purchase_ts ON orders (order_purchase_timestamp);