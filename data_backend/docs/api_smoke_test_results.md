# Siyyarte — API Smoke Test Spec & Expected Results

> **Environment note:** no live backend here. This is the executable test spec (run with `postman_collection.json`). "Expected" = the assertion each case must satisfy. The cross-cutting invariant: **no endpoint may return an unverified number.**

| # | Endpoint | Test case | Fixture | Expected assertion |
|---|----------|-----------|---------|--------------------|
| 1 | `/v1/vehicles` | Complete Grade-A | Chevrolet Tahoe 2023 5.3L (NA) | beta_status=Beta_Ready; available_fields includes oil/coolant/tank; 200 |
| 2 | `/v1/specs/{id}/fluids` | Partial — capacity blocked | Kia Rio (GCC) | oil **spec** Verified; oil/coolant/tank `value:null, verification_status:"Not Verified"` |
| 3 | `/v1/vehicles` | US-spec American | Ford F-150 (NA) | market_scope="North America"; market badge field present |
| 4 | `/v1/specs/{id}/fluids` | GCC-spec Korean | Hyundai Tucson (GCC) | values present; source = en_GN; market_scope="GCC" |
| 5 | `/v1/route-market` | Market confirmation required | Tahoe, clues sparse | confidence_score<0.7; required_user_confirmation_fields non-empty; reason_codes present |
| 6 | `/v1/unsupported` (POST) | Unsupported vehicle | Changan model | 201; vin stored as hash only; row in unsupported_vehicle_requests |
| 7 | `/v1/specs/{id}/fluids` | EV blocked | BYD Atto 3 | engine-oil field absent (EV); status Blocked_OCR; **no numbers** |
| 8 | `/v1/specs/{id}` | Source blocked | GMC Terrain intervals | interval fields `verification_status:"Not Verified"` (QUEUED) |
| 9 | `/v1/vehicles` | Data unavailable | unknown model | empty available_records + "request this vehicle" hint |
| 10 | `/v1/health/qa` | QA health check | — | returns qa_master_gate total; 200 only if 0 |

**Global assertion (all cases):** every numeric field in any 200 response is accompanied by `source_document`, `page`, `grade='A'`, `verification_status='Verified'`. A failing case → log to `failed_cases_log.md` and block release.
