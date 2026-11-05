CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS intermediate;
CREATE SCHEMA IF NOT EXISTS marts;

CREATE TABLE raw.customers (
    customer_id text, customer_unique_id text, customer_zip_code_prefix text,
    customer_city text, customer_state text,
    _loaded_at timestamptz DEFAULT now()
);

CREATE TABLE raw.orders (
    order_id text, customer_id text, order_status text,
    order_purchase_timestamp timestamp, order_approved_at timestamp,
    order_delivered_carrier_date timestamp, order_delivered_customer_date timestamp,
    order_estimated_delivery_date timestamp,
    _loaded_at timestamptz DEFAULT now()
);

CREATE TABLE raw.order_items (
    order_id text, order_item_id int, product_id text, seller_id text,
    shipping_limit_date timestamp, price numeric(10,2), freight_value numeric(10,2),
    _loaded_at timestamptz DEFAULT now()
);

CREATE TABLE raw.order_payments (
    order_id text, payment_sequential int, payment_type text,
    payment_installments int, payment_value numeric(10,2),
    _loaded_at timestamptz DEFAULT now()
);

CREATE TABLE raw.order_reviews (
    review_id text, order_id text, review_score int, review_comment_title text,
    review_comment_message text, review_creation_date timestamp,
    review_answer_timestamp timestamp,
    _loaded_at timestamptz DEFAULT now()
);
