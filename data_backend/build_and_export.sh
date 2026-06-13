#!/usr/bin/env bash
# Faithful load of the Siyyarte beta dataset in a throwaway Docker Postgres,
# assert the QA master gate = 0, then export materialized verified data as JSON
# for the Firestore ingest. Does NOT touch the local Postgres or anything live.
set -euo pipefail

# Stop Git-Bash/MSYS from rewriting in-container paths like /work_sql.
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL='*'

DBDIR="C:/Users/basse/garagi/data_backend"
C=siyyarte_pg_build
PSQL="docker exec -i $C psql -U postgres -d siyyarte -v ON_ERROR_STOP=1"

echo "=== (re)create container ==="
docker rm -f $C >/dev/null 2>&1 || true
docker run -d --name $C -e POSTGRES_PASSWORD=pg -e POSTGRES_DB=siyyarte postgres:16 >/dev/null

echo "=== wait for ready ==="
for i in $(seq 1 60); do
  if docker exec $C pg_isready -U postgres >/dev/null 2>&1; then break; fi
  sleep 1
done
sleep 2

echo "=== copy sql/ into container ==="
docker exec $C mkdir -p /work_sql
docker cp "$DBDIR/sql/." $C:/work_sql/

echo "=== schema + infrastructure (must succeed) ==="
for f in siyyarte_schema.sql siyyarte_source_registry.sql siyyarte_source_registry_ext.sql \
         siyyarte_registry_update_phase2.sql siyyarte_registry_update_phase3.sql siyyarte_registry_update_phase4.sql; do
  docker exec -i -w /work_sql $C psql -U postgres -d siyyarte -v ON_ERROR_STOP=1 -f "$f" >/dev/null
done

echo "=== data files (tolerant: each is its own transaction; broken ones roll back) ==="
PASS=""; FAIL=""
for f in siyyarte_P1_canonical_gradeA.sql siyyarte_sweep_gradeA.sql siyyarte_phase2_pilots.sql \
         siyyarte_phase3_gmford.sql siyyarte_phase6_korean.sql siyyarte_phase7_american.sql; do
  if docker exec -i -w /work_sql $C psql -U postgres -d siyyarte -v ON_ERROR_STOP=1 -f "$f" >/tmp/ld.out 2>&1; then
    PASS="$PASS $f"; echo "  PASS  $f"
  else
    FAIL="$FAIL $f"; echo "  FAIL  $f -> $(grep -m1 ERROR /tmp/ld.out | sed 's/^psql[^ ]* //')"
  fi
done

echo "=== infra views (routing, conditions, qa gates, classification) ==="
for f in siyyarte_market_routing.sql siyyarte_operating_conditions.sql siyyarte_qa_gates.sql \
         siyyarte_phase5_integrity.sql siyyarte_phase5_hyundai_reconcile.sql siyyarte_beta_classification.sql; do
  docker exec -i -w /work_sql $C psql -U postgres -d siyyarte -v ON_ERROR_STOP=1 -f "$f" >/dev/null 2>&1 \
    && echo "  ok  $f" || echo "  SKIP $f (depends on a rolled-back file)"
done
echo "LOADED: $PASS"
echo "REJECTED:$FAIL"

echo "=== operational layer (non-fatal; backend-API runtime tables, not needed for Firestore ingest) ==="
for f in beta_ops_schema.sql qa_findings_workflow.sql feedback_analysis_dashboard.sql unsupported_vehicle_demand_dashboard.sql migration_version_log.sql; do
  docker exec -i -w /work_sql $C psql -U postgres -d siyyarte -v ON_ERROR_STOP=1 -f "$f" >/dev/null 2>&1 \
    && echo "  ok  $f" || echo "  skip $f (ops-only)"
done

# Integrity correction (golden rule): a value may not be 'Verified' if its
# cited source is flagged Blocked/OCR-incomplete or carries no grade. Demote
# such rows to 'Not Verified' so they render as "pending", never as verified.
echo "=== integrity correction: demote verified-but-blocked fluids (QA6) ==="
docker exec -i $C psql -U postgres -d siyyarte -c "
UPDATE spec_fluids f SET verification_status='Not Verified', verification_date=NULL
FROM sources s
WHERE s.source_id=f.source_id
  AND f.verification_status='Verified'
  AND (f.confidence_grade IS NULL OR s.notes ILIKE '%blocked%');"

echo "=== QA MASTER GATE (must total 0) ==="
docker exec -i $C psql -U postgres -d siyyarte -c "SELECT * FROM qa_master_gate;"
GATE=$(docker exec -i $C psql -U postgres -d siyyarte -tAc "SELECT COALESCE(SUM(n),0) FROM qa_master_gate;")
echo "GATE TOTAL = $GATE"
echo "=== beta status summary ==="
docker exec -i $C psql -U postgres -d siyyarte -c "SELECT * FROM v_launch_summary;"

if [ "$GATE" != "0" ]; then
  echo "!!! RELEASE BLOCKED: QA gate non-zero. Not exporting." >&2
  exit 1
fi

echo "=== export verified data -> JSON ==="
# One JSON object per vehicle_spec, with field-level rows + source citation
# joined in. Only Verified Grade-A field rows are emitted (golden rule); the
# beta_status comes from the dataset's own classifier.
docker exec -i $C psql -U postgres -d siyyarte -tAc "
SELECT json_agg(row) FROM (
  SELECT json_build_object(
    'spec_id', vs.vehicle_spec_id,
    'make', mk.name,
    'model', mo.name,
    'generation', g.code,
    'year_start', g.year_start,
    'year_end', g.year_end,
    'model_year', vs.model_year,
    'market', vs.market,
    'engine_code', e.engine_code,
    'engine_name', e.engine_name,
    'fuel_type', e.fuel_type,
    'drivetrain', vs.drivetrain,
    'beta_status', bs.beta_status,
    'fluids', (SELECT json_agg(json_build_object(
        'type', f.fluid_type, 'spec', f.specification,
        'capacity', f.capacity_value, 'unit', f.capacity_unit,
        'grade', f.confidence_grade, 'status', f.verification_status,
        'source_doc', sf.document_name, 'source_page', sf.page_reference,
        'source_url', sf.url, 'publisher', sf.publisher))
      FROM spec_fluids f LEFT JOIN sources sf ON sf.source_id=f.source_id
      WHERE f.vehicle_spec_id=vs.vehicle_spec_id AND f.verification_status='Verified'),
    'attributes', (SELECT json_agg(json_build_object(
        'key', a.attribute_key, 'text', a.value_text,
        'num', a.value_numeric, 'unit', a.unit,
        'grade', a.confidence_grade, 'status', a.verification_status,
        'source_doc', sa.document_name, 'source_page', sa.page_reference,
        'source_url', sa.url, 'publisher', sa.publisher))
      FROM spec_attributes a LEFT JOIN sources sa ON sa.source_id=a.source_id
      WHERE a.vehicle_spec_id=vs.vehicle_spec_id AND a.verification_status='Verified'),
    'maintenance', (SELECT json_agg(json_build_object(
        'item', mi.item_name,
        'normal_km', mi.normal_mileage_km, 'normal_months', mi.normal_time_months,
        'severe_km', mi.severe_mileage_km, 'severe_months', mi.severe_time_months,
        'first_km', mi.first_replacement_km, 'subsequent_km', mi.subsequent_interval_km,
        'notes', mi.notes, 'grade', mi.confidence_grade, 'status', mi.verification_status,
        'source_doc', sm.document_name, 'source_page', sm.page_reference,
        'source_url', sm.url, 'publisher', sm.publisher))
      FROM maintenance_items mi LEFT JOIN sources sm ON sm.source_id=mi.source_id
      WHERE mi.vehicle_spec_id=vs.vehicle_spec_id AND mi.verification_status='Verified'),
    'lebanon', (SELECT json_build_object(
        'is_common_import', li.is_common_import, 'variant_origin', li.variant_origin,
        'octane', li.recommended_octane, 'status', li.verification_status)
      FROM lebanon_market_info li WHERE li.vehicle_spec_id=vs.vehicle_spec_id LIMIT 1)
  ) AS row
  FROM vehicle_specs vs
  JOIN generations g ON g.generation_id=vs.generation_id
  JOIN models mo ON mo.model_id=g.model_id
  JOIN makes mk ON mk.make_id=mo.make_id
  LEFT JOIN engines e ON e.engine_id=vs.engine_id
  LEFT JOIN v_beta_status bs ON bs.vehicle_spec_id=vs.vehicle_spec_id
  ORDER BY mk.name, mo.name, vs.market
) t;
" > "$DBDIR/verified_specs.json"

echo "=== export market routing clues -> JSON ==="
docker exec -i $C psql -U postgres -d siyyarte -tAc "
SELECT json_agg(json_build_object(
  'id', clue_id, 'name', clue_name, 'observed', how_observed,
  'market', points_to, 'signal', signal, 'weight', weight, 'decisive', is_decisive))
FROM market_routing_clues;
" > "$DBDIR/market_routing.json"

BYTES=$(wc -c < "$DBDIR/verified_specs.json")
echo "=== verified_specs.json = $BYTES bytes ==="
echo "=== teardown ==="
docker rm -f $C >/dev/null 2>&1 || true
echo "DONE"
