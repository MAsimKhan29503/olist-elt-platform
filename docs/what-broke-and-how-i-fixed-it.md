# What broke and how I fixed it

## 1. Warehouse init scripts did not run
**Symptom:** I added `01_schemas.sql` to the warehouse init folder, but the `raw` tables did not exist.
**Cause:** The Postgres image runs scripts in `docker-entrypoint-initdb.d` only when its data volume is empty. The warehouse had already started once.
**Fix:** Stopped the container, removed only the warehouse volume, and started it again. For later scripts (`02_`, `03_`) I applied them to the running database with `psql`, and also kept them in the init folder so a fresh `docker compose up` builds everything.

## 2. A manual test run loaded the wrong day
**Symptom:** I ran `airflow dags test ... 2018-01-05` to load 5 January, but the log said it loaded 4 January (258 orders instead of 210).
**Cause:** For manual runs, the date I pass is the END of the data interval, so the window covers the day before. In scheduled runs and backfills the date is the START.
**Fix:** Passed 2018-01-06 to load 5 January. Lesson: always read the window printed in the task log before trusting a test.

## 3. Backfill skipped days after manual runs
**Symptom:** After deleting a week of orders and running a backfill, the table was 426 rows short.
**Cause:** My earlier manual test runs left successful DAG runs with offset windows. The backfill trusted those old runs and skipped the days. `--reset-dagruns` re-ran them but kept their wrong windows.
**Fix:** Deleted the DAG's run history with `airflow dags delete` (metadata only, no data touched), then backfilled again. All seven days loaded and the count matched the source (99,441).
**Takeaway:** Loads are idempotent (delete the window, then insert), so re-running any day is safe. Keep manual test runs away from dates I plan to backfill.


## 4. dbt ignored an edit to a yml file
**Symptom:** I added tests for `dim_sellers` to `_marts.yml`, but `dbt build` did not run them (39 tests found instead of 41).
**Cause:** dbt reused its cached parse of the project (partial parsing) and did not see the change.
**Fix:** Ran dbt with `--no-partial-parse`; the two missing tests appeared and passed.

## 5. dbt installed a beta version
**Symptom:** `dbt --version` showed `1.13.0-b1`.
**Cause:** I had not pinned versions, so pip picked a pre-release.
**Fix:** Pinned `dbt-core==1.12.6` and `dbt-postgres==1.11.0` in the Dockerfile.