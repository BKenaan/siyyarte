# Siyyarte — Controlled Beta Launch Checklist

## Pre-launch gates (all must pass)
- [ ] `beta_dataset_v0_1.sql` loaded to production; load completed without error
- [ ] `SELECT SUM(n) FROM qa_master_gate` = **0**
- [ ] API contract test: **no endpoint returns a numeric value without** (source + page + grade A + Verified) — run `postman_collection.json`
- [ ] VIN never stored raw — `beta_registrations.vin_hash` / `unsupported_vehicle_requests.vin_hash` are SHA-256 only
- [ ] Unsupported capture writes to `unsupported_vehicle_requests` (test one submission)
- [ ] Market-routing returns confirmation fields when confidence < 0.7 (test Tahoe)
- [ ] Frontend: 7 display states render per `frontend_state_test_results.md`; no blank/0/N-A as data
- [ ] `release_versions` row recorded with `qa_gate_total=0`, `promoted_to='production'`
- [ ] Rollback script staged; previous version tag retained
- [ ] Release notes attached to deployment

## Launch scope
Beta_Ready (~34 models) render values; Beta_Partial shown honestly; Not_Ready/blocked/unavailable → status + capture flow.

## Post-launch (day 0)
- [ ] Smoke 5 real vehicles (Corolla GCC, Tahoe US, Tucson GCC, Patrol partial, a Not_Ready)
- [ ] Confirm `beta_daily_metrics` populating
- [ ] Confirm citation views logging
