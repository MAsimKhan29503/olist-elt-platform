FROM apache/airflow:2.10.5-python3.11
USER airflow
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt
RUN python -m venv /home/airflow/dbt_venv && \
    /home/airflow/dbt_venv/bin/pip install --no-cache-dir dbt-core==1.12.6 dbt-postgres==1.11.0