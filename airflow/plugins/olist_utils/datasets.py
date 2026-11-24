from airflow.datasets import Dataset

RAW_ORDERS = Dataset("postgres://warehouse/olist_dw/raw/orders")
RAW_DB_TABLES = Dataset("postgres://warehouse/olist_dw/raw/db_tables")
RAW_VENDOR_FILES = Dataset("postgres://warehouse/olist_dw/raw/vendor_files")
RAW_FX_RATES = Dataset("postgres://warehouse/olist_dw/raw/fx_rates")  