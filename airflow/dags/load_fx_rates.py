import pendulum
import requests
from airflow.decorators import dag, task
from airflow.providers.postgres.hooks.postgres import PostgresHook
from psycopg2.extras import execute_values

API_URL = "https://api.frankfurter.dev/v2/rates"
BASE = "BRL"
QUOTE = "USD"
START_DATE = "2016-09-01"
END_DATE = "2018-10-31"


@dag(
    dag_id="load_fx_rates",
    start_date=pendulum.datetime(2026, 11, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    default_args={"retries": 3, "retry_delay": pendulum.duration(minutes=2)},
    tags=["olist", "ingestion", "api"],
)
def load_fx_rates():
    @task
    def fetch_and_load() -> int:
        response = requests.get(
            API_URL,
            params={"base": BASE, "quotes": QUOTE, "from": START_DATE, "to": END_DATE},
            timeout=30,
        )
        response.raise_for_status()
        data = response.json()

        if not data:
            raise ValueError("API returned no rates")

        rows = [(d["date"], d["base"], d["quote"], d["rate"]) for d in data]

        warehouse = PostgresHook(postgres_conn_id="warehouse_pg")
        conn = warehouse.get_conn()
        try:
            with conn.cursor() as cur:
                execute_values(
                    cur,
                    "INSERT INTO raw.fx_rates "
                    "(rate_date, base_currency, quote_currency, rate) VALUES %s "
                    "ON CONFLICT (rate_date, base_currency, quote_currency) "
                    "DO UPDATE SET rate = EXCLUDED.rate, _loaded_at = now()",
                    rows,
                )
            conn.commit()
        finally:
            conn.close()
        return len(rows)

    fetch_and_load()


load_fx_rates()