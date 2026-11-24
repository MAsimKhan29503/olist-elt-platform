import pendulum
from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from olist_utils.callbacks import record_failure
from olist_utils.datasets import (
    RAW_DB_TABLES,
    RAW_FX_RATES,
    RAW_ORDERS,
    RAW_VENDOR_FILES,
)

DBT = "/home/airflow/dbt_venv/bin/dbt"
DBT_DIR = "/opt/airflow/dbt"


@dag(
    dag_id="dbt_build",
    start_date=pendulum.datetime(2026, 11, 1, tz="UTC"),
    schedule=[RAW_ORDERS, RAW_DB_TABLES, RAW_VENDOR_FILES, RAW_FX_RATES],
    catchup=False,
    default_args={
        "retries": 1,
        "retry_delay": pendulum.duration(minutes=2),
        "on_failure_callback": record_failure,
    },
    tags=["olist", "dbt"],
)
def dbt_build():
    BashOperator(
        task_id="dbt_build",
        bash_command=f"cd {DBT_DIR} && {DBT} build",
    )


dbt_build()