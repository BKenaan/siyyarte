# Siyyarte Beta v0.1 — Claude Code Build Bundle

Start here: read `docs/Siyyarte_Beta_Launch_Handoff_and_SignOff.md` (the executive spec), then build.

## Load order (PostgreSQL 14+)
> Run psql FROM the `sql/` directory (the master file uses relative `\i` includes).
```
cd sql
psql -d siyyarte -f beta_dataset_v0_1.sql      # schema + registry + all Grade-A data + QA gates + classification
                                               #   -> prints qa_master_gate rows; must end "RELEASE OK"
# then load the operational (runtime) layer:
psql -d siyyarte -f beta_ops_schema.sql
psql -d siyyarte -f qa_findings_workflow.sql
psql -d siyyarte -f feedback_analysis_dashboard.sql
psql -d siyyarte -f unsupported_vehicle_demand_dashboard.sql
psql -d siyyarte -f migration_version_log.sql
```
Gate must return 0 before exposing data:
```
SELECT SUM(n) FROM qa_master_gate;   -- must be 0
```

## Build the app
- Backend: `docs/Siyyarte_Backend_API_Plan.md` + `docs/Siyyarte_API_Contract.md`. Read ONLY Verified-A values (never emit a number without source+page+grade A+Verified).
- Routing: `docs/Siyyarte_Market_Routing_Model.md` + `docs/Siyyarte_US_GCC_Modeling.md` (ask user when confidence < 0.7).
- Frontend: `docs/Siyyarte_Frontend_Implementation_Guide.md` + `docs/Siyyarte_Display_State_Test_Cases.md` + open `docs/Siyyarte_Display_States_Mockup.html`. UI strings in `ui_copy/`.
- CI: `ci/siyyarte_cicd_qa_gate.sh` (block deploy if gate != 0). API tests: `ci/postman_collection.json`. Source archiving: `ci/siyyarte_archive_ingest.py`.

## Golden rule
Incomplete coverage is fine. An unverified displayed value is not. Beta_Ready renders values; Beta_Partial/Not_Ready/Blocked show honest status, never numbers.

## NOT included (intentionally)
Deprecated per-vehicle seeds (superseded by `siyyarte_P1_canonical_gradeA.sql`) and the spreadsheet-generator scripts — they are not app inputs.
