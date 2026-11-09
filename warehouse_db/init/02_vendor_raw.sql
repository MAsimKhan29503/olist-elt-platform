CREATE TABLE IF NOT EXISTS raw.products (
    product_id                 text,
    product_category_name      text,
    product_name_lenght        int,
    product_description_lenght int,
    product_photos_qty         int,
    product_weight_g           int,
    product_length_cm          int,
    product_height_cm          int,
    product_width_cm           int,
    _source_file               text,
    _loaded_at                 timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS raw.sellers (
    seller_id              text,
    seller_zip_code_prefix text,
    seller_city            text,
    seller_state           text,
    _source_file           text,
    _loaded_at             timestamptz DEFAULT now()
);