import os

import pendulum
from airflow.decorators import dag, task
from airflow.exceptions import AirflowSkipException
from airflow.providers.postgres.hooks.postgres import PostgresHook

DROP_FOLDER = "/opt/airflow/data/vendor_drop"

VENDOR_FILES = {
    "products": [
        "product_id", "product_category_name", "product_name_lenght",
        "product_description_lenght", "product_photos_qty", "product_weight_g",
        "product_length_cm", "product_height_cm", "product_width_cm",
    ],
    "sellers": [
        "seller_id", "seller_zip_code_prefix", "seller_city", "seller_state",
    ],
}


@dag(
    dag_id="load_vendor_files",
    start_date=pendulum.datetime(2026, 11, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    default_args={"retries": 2, "retry_delay": pendulum.duration(minutes=1)},
    tags=["olist", "ingestion"],
)
def load_vendor_files():
    @task
    def load_file(name: str) -> int:
        filename = f"{name}.csv"
        path = os.path.join(DROP_FOLDER, filename)

        if not os.path.exists(path):
            raise AirflowSkipException(f"{filename} not found, nothing to load")

        cols = ", ".join(VENDOR_FILES[name])
        warehouse = PostgresHook(postgres_conn_id="warehouse_pg")
        conn = warehouse.get_conn()
        try:
            with conn.cursor() as cur:
                cur.execute(f"TRUNCATE raw.{name}")
                with open(path, encoding="utf-8") as f:
                    cur.copy_expert(
                        f"COPY raw.{name} ({cols}) "
                        "FROM STDIN WITH (FORMAT csv, HEADER true)",
                        f,
                    )
                cur.execute(
                    f"UPDATE raw.{name} SET _source_file = %s "
                    "WHERE _source_file IS NULL",
                    (filename,),
                )
                rows = cur.rowcount
            conn.commit()
        finally:
            conn.close()
        return rows

    load_file.expand(name=list(VENDOR_FILES))


load_vendor_files()