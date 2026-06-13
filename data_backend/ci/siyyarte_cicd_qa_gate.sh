#!/usr/bin/env bash
# Siyyarte CI/CD release gate. Exit 0 = deploy allowed; non-zero = BLOCKED.
set -euo pipefail
DB="${1:-siyyarte}"
echo "[1/4] Running qa_master_gate..."
TOTAL=$(psql -d "$DB" -At -c "SELECT COALESCE(SUM(n),0) FROM qa_master_gate;")
if [ "$TOTAL" != "0" ]; then
  echo "[BLOCKED] qa_master_gate returned $TOTAL violation(s). Exporting failed rows..."
  psql -d "$DB" -c "\copy (SELECT * FROM qa_master_gate WHERE n>0) TO 'qa_failures_$(date +%F).csv' CSV HEADER"
  for v in qa_v01_verified_no_source qa_v02_verified_no_page qa_v05_cross_market_source qa_v07_ev_with_ice_fields qa_v09_capacity_no_unit qa_v12_eu_source_gcc_value; do
     psql -d "$DB" -c "\copy (SELECT '$v' rule, * FROM $v) TO 'qa_detail_${v}_$(date +%F).csv' CSV HEADER" || true
  done
  echo "[ACTION] Review qa_failures_*.csv -> fix rows -> manual approval required to retry. Deployment HALTED."
  exit 1
fi
echo "[2/4] Gate passed (0 violations)."
echo "[3/4] Snapshot beta status:"; psql -d "$DB" -c "SELECT * FROM v_launch_summary;"
echo "[4/4] APPROVED for deployment."
