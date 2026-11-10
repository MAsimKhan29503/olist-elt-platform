import os
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
    dag_id="extract_orders_incremental",
    start_date=pendulum.datetime(2016, 9, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    max_active_runs=4,
    default_args={"retries": 2, "retry_delay": pendulum.duration(minutes=1)},
    tags=["olist", "ingestion", "incremental"],
)
def extract_orders_incremental():
    @task
    def load_window(data_interval_start=None, data_interval_end=None) -> int:
        start = data_interval_start.strftime("%Y-%m-%d %H:%M:%S")
        end = data_interval_end.strftime("%Y-%m-%d %H:%M:%S")

        source = PostgresHook(postgres_conn_id="source_pg")
        warehouse = PostgresHook(postgres_conn_id="warehouse_pg")

        with tempfile.NamedTemporaryFile("w+", suffix=".csv", delete=False) as f:
            tmp_path = f.name
        try:
            source.copy_expert(
                f"COPY (SELECT {COLUMNS} FROM public.orders "
                f"WHERE order_purchase_timestamp >= '{start}' "
                f"AND order_purchase_timestamp < '{end}') TO STDOUT WITH CSV",
                tmp_path,
            )

            conn = warehouse.get_conn()
            try:
                with conn.cursor() as cur:
                    cur.execute(
                        "DELETE FROM raw.orders "
                        "WHERE order_purchase_timestamp >= %s "
                        "AND order_purchase_timestamp < %s",
                        (start, end),
                    )
                    with open(tmp_path, encoding="utf-8") as g:
                        cur.copy_expert(
                            f"COPY raw.orders ({COLUMNS}) FROM STDIN WITH CSV", g
                        )
                    loaded = cur.rowcount
                conn.commit()
            finally:
                conn.close()
        finally:
            os.remove(tmp_path)

        print(f"Window {start} to {end}: loaded {loaded} orders")
        return loaded

    load_window()


extract_orders_incremental()