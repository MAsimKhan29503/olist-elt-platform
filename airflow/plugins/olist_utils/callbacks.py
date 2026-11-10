import logging

from airflow.providers.postgres.hooks.postgres import PostgresHook

log = logging.getLogger(__name__)


def record_failure(context):
    """Called by Airflow when a task has failed for good (after all retries)."""
    ti = context["task_instance"]
    error = str(context.get("exception") or "unknown error")[:2000]

    log.error("PIPELINE FAILURE: %s.%s run=%s error=%s",
              ti.dag_id, ti.task_id, ti.run_id, error)

    try:
        PostgresHook(postgres_conn_id="warehouse_pg").run(
            "INSERT INTO ops.pipeline_failures "
            "(dag_id, task_id, run_id, try_number, error_message, log_url) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            parameters=(ti.dag_id, ti.task_id, ti.run_id,
                        ti.try_number, error, ti.log_url),
        )
    except Exception:
        # The alert itself must never crash the pipeline
        log.exception("Could not write the failure record")