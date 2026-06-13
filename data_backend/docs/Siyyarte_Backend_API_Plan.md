# Siyyarte — Backend API Integration Plan (beta)

Builds on `Siyyarte_API_Contract.md`. All endpoints read ONLY from `v_beta_status` Beta_Ready/Partial specs; values surface only if `verification_status='Verified' AND confidence_grade='A'`.

## Endpoints
### `GET /v1/vehicles` (selection)
Returns: brand, model, generation, year_range, trim, engine, market_scope, **beta_status**, **available_fields**, **missing_fields**.
SQL: join `v_beta_status` + per-spec field presence; `available_fields` = Verified-A fields, `missing_fields` = NULL/Not-Verified (with their blocked reason).

### `POST /v1/route-market`
Returns: likely_market, confidence_score, **reason_codes**, required_user_confirmation_fields, matching_vehicle_records. Backed by `market_routing_clues`. **If confidence_score < 0.7 → return confirmation fields; the app must ASK, not auto-choose.**

### `GET /v1/specs/{id}/fluids`
Returns ONLY verified rows: fluid_type, specification, capacity, unit, source_document, page/section, verification_status. Unverified fluids returned with `value:null, verification_status` (rendered as status, not 0).

### `GET /v1/specs/{id}/maintenance?service=normal|severe`
Returns: service_item, interval_km, interval_months, **severe_service_rule (only if official)**, source_document, citation, verification_status. Never a number without source.

## Read model
- A materialized `beta_api_view` (join of vehicle_specs + beta_status + fluids + maintenance + sources) refreshed on release; the API reads the view, not raw tables.
- The view EXCLUDES any non-Verified-A value from numeric fields by construction → the API physically cannot emit an unverified number.
