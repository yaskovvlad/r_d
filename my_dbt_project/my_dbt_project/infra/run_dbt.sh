#!/bin/bash
set -euo pipefail

export DBT_PROFILES_DIR=/root/.dbt
cd /usr/app

echo "[$(date -Is)] Starting dbt job ..."
# Якщо користуєшся пакетами:
dbt deps || true

# Якщо хочеш пересіювати час від часу — розкоментуй:
# dbt seed --full-refresh

dbt run
dbt test
echo "[$(date -Is)] dbt job completed."
