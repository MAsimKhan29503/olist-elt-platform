import tempfile

import pendulum
from airflow.decorators import dag, task
from airflow.providers.postgres.hooks.postgres import PostgresHook

COLUMNS = (
    "order_id, customer_id, order_status, order_purchase_timestamp, "
    "order_approved_at, order_delivered_carrier_date, "
    "order_delivered_customer_date, order_estimated_delivery_date"
)


@dag(
    dag_id="extract_orders_to_raw",
    start_date=pendulum.datetime(2026, 11, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    tags=["olist"],
)
def extract_orders_to_raw():
    @task
    def load_orders():
        source = PostgresHook(postgres_conn_id="source_pg")
        warehouse = PostgresHook(postgres_conn_id="warehouse_pg")

        with tempfile.NamedTemporaryFile("w+", suffix=".csv") as f:
            source.copy_expert(
                f"COPY (SELECT {COLUMNS} FROM public.orders) TO STDOUT WITH CSV",
                f.name,
            )
            warehouse.run("TRUNCATE raw.orders")
            warehouse.copy_expert(
                f"COPY raw.orders ({COLUMNS}) FROM STDIN WITH CSV",
                f.name,
            )

    load_orders()


extract_orders_to_raw()