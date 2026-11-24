-- Builds a small, consistent sample of the raw layer and exports it as CSV files.

CREATE TEMP TABLE sample_orders AS
SELECT order_id
FROM raw.orders
ORDER BY md5(order_id)
LIMIT 300;

COPY (
    SELECT order_id, customer_id, order_status, order_purchase_timestamp,
           order_approved_at, order_delivered_carrier_date,
           order_delivered_customer_date, order_estimated_delivery_date
    FROM raw.orders
    WHERE order_id IN (SELECT order_id FROM sample_orders)
    ORDER BY order_id
) TO '/tmp/ci_sample/orders.csv' WITH CSV HEADER;

COPY (
    SELECT customer_id, customer_unique_id, customer_zip_code_prefix,
           customer_city, customer_state
    FROM raw.customers
    WHERE customer_id IN (
        SELECT customer_id FROM raw.orders
        WHERE order_id IN (SELECT order_id FROM sample_orders)
    )
    ORDER BY customer_id
) TO '/tmp/ci_sample/customers.csv' WITH CSV HEADER;

COPY (
    SELECT order_id, order_item_id, product_id, seller_id,
           shipping_limit_date, price, freight_value
    FROM raw.order_items
    WHERE order_id IN (SELECT order_id FROM sample_orders)
    ORDER BY order_id, order_item_id
) TO '/tmp/ci_sample/order_items.csv' WITH CSV HEADER;

COPY (
    SELECT order_id, payment_sequential, payment_type,
           payment_installments, payment_value
    FROM raw.order_payments
    WHERE order_id IN (SELECT order_id FROM sample_orders)
    ORDER BY order_id, payment_sequential
) TO '/tmp/ci_sample/order_payments.csv' WITH CSV HEADER;

COPY (
    SELECT review_id, order_id, review_score, review_comment_title,
           review_comment_message, review_creation_date, review_answer_timestamp
    FROM raw.order_reviews
    WHERE order_id IN (SELECT order_id FROM sample_orders)
    ORDER BY review_id, order_id
) TO '/tmp/ci_sample/order_reviews.csv' WITH CSV HEADER;

COPY (
    SELECT product_id, product_category_name, product_name_lenght,
           product_description_lenght, product_photos_qty, product_weight_g,
           product_length_cm, product_height_cm, product_width_cm
    FROM raw.products
    WHERE product_id IN (
        SELECT product_id FROM raw.order_items
        WHERE order_id IN (SELECT order_id FROM sample_orders)
    )
    ORDER BY product_id
) TO '/tmp/ci_sample/products.csv' WITH CSV HEADER;

COPY (
    SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state
    FROM raw.sellers
    WHERE seller_id IN (
        SELECT seller_id FROM raw.order_items
        WHERE order_id IN (SELECT order_id FROM sample_orders)
    )
    ORDER BY seller_id
) TO '/tmp/ci_sample/sellers.csv' WITH CSV HEADER;

COPY (
    SELECT rate_date, base_currency, quote_currency, rate
    FROM raw.fx_rates
    ORDER BY rate_date
) TO '/tmp/ci_sample/fx_rates.csv' WITH CSV HEADER;