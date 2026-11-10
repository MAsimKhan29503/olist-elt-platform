CREATE SCHEMA IF NOT EXISTS ops;

CREATE TABLE IF NOT EXISTS ops.pipeline_failures (
    id            bigserial PRIMARY KEY,
    failed_at     timestamptz DEFAULT now(),
    dag_id        text,
    task_id       text,
    run_id        text,
    try_number    int,
    error_message text,
    log_url       text
);