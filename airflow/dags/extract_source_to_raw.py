import tempfile

import pendulum
from airflow.decorators import dag, task
from airflow.providers.postgres.hooks.postgres import PostgresHook

TABLES = {
    "customers": [
        "customer_id", "customer_unique_id", "customer_zip_code_prefix",
        "customer_city", "customer_state",
    ],
    "orders": [
        "order_id", "customer_id", "order_status", "order_purchase_timestamp",
        "order_approved_at", "order_delivered_carrier_date",
        "order_delivered_customer_date", "order_estimated_delivery_date",
    ],
    "order_items": [
        "order_id", "order_item_id", "product_id", "seller_id",
        "shipping_limit_date", "price", "freight_value",
    ],
    "order_payments": [
        "order_id", "payment_sequential", "payment_type",
        "payment_installments", "payment_value",
    ],
    "order_reviews": [
        "review_id", "order_id", "review_score", "review_comment_title",
        "review_comment_message", "review_creation_date",
        "review_answer_timestamp",
    ],
}


@dag(
    dag_id="extract_source_to_raw",
    start_date=pendulum.datetime(2026, 11, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    default_args={"retries": 2, "retry_delay": pendulum.duration(minutes=1)},
    tags=["olist", "ingestion"],
)
def extract_source_to_raw():
    @task
    def load_table(table: str) -> str:
        cols = ", ".join(TABLES[table])
        source = PostgresHook(postgres_conn_id="source_pg")
        warehouse = PostgresHook(postgres_conn_id="warehouse_pg")

        with tempfile.NamedTemporaryFile("w+", suffix=".csv") as f:
            source.copy_expert(
                f"COPY (SELECT {cols} FROM public.{table}) TO STDOUT WITH CSV",
                f.name,
            )
            warehouse.run(f"TRUNCATE raw.{table}")
            warehouse.copy_expert(
                f"COPY raw.{table} ({cols}) FROM STDIN WITH CSV",
                f.name,
            )
        return table

    load_table.expand(table=list(TABLES))


extract_source_to_raw() 