# Siyyarte — Product-Ready API Contract (v1)

**Principle:** the app must **never display uncertain data as final.** Every value ships with grade, source, and verification status; market is resolved before specs are shown.

## 1. Vehicle Selection
`GET /v1/vehicles?brand&model&year&trim&engine&market`
Returns the candidate records and what still needs disambiguating.
```json
{
  "query": {"brand":"Chevrolet","model":"Tahoe","year":2023,"engine":"5.3L V8"},
  "available_records": [
    {"vehicle_spec_id":1411,"generation":"T1XX","trim":null,"engine":"L84 5.3L V8",
     "transmission":"10-spd auto","market":"North America","completeness":"full",
     "confidence_level":"A"}
  ],
  "markets_available": ["North America"],        // from v_market_options
  "market_confirmation_required": false           // true if >1 market record
}
```

## 2. Market Routing
`POST /v1/route-market` body: `{make,model,year,engine, clues:{vin?,odometer_unit?,octane_label?,manual_region?,...}}`
```json
{
  "likely_market": "North America",
  "confidence_score": 0.82,
  "required_user_confirmation_fields": [],         // populated when score < 0.7
  "matching_vehicle_records": [1411],
  "reason_codes": ["ODO_UNIT=miles(+0.40)","FUEL_OCTANE_LABEL=AKI(+0.35)","ENGINE_AVAIL=L87_US_only(decisive)"]
}
```
Rules: market-exclusive engine or user-stated origin ⇒ decisive (≥0.9). Below 0.7 ⇒ return `required_user_confirmation_fields` and ask; never auto-assume.

## 3. Maintenance Profile
`GET /v1/specs/{id}/maintenance?service=normal|severe`
```json
{ "market":"North America",
  "items":[
   {"item":"Engine Oil & Filter","interval_km":null,"interval_months":12,
    "severe_service_adjustment":null,
    "source_grade":"A","source_document":"2023 Chevrolet Tahoe OM",
    "page":"401","verification_status":"Verified",
    "note":"GM Oil Life System (algorithmic); min once/yr"},
   {"item":"Engine Coolant","interval_km":240000,"interval_months":72,
    "source_grade":"A","source_document":"2023 Chevrolet Tahoe OM","page":"401","verification_status":"Verified"}
  ]}
```
`severe_service_adjustment` is **only** populated when official (e.g. GCC dusty/desert clause); otherwise `null`, never inferred.

## 4. Fluids Profile
`GET /v1/specs/{id}/fluids`
```json
{ "fluids":[
   {"fluid_type":"Engine Oil","specification":"dexos1 full synthetic, SAE 0W-20",
    "capacity":7.6,"unit":"L (with filter)",
    "source":"2023 Chevrolet Tahoe OM","page":"408","grade":"A","verification_status":"Verified"},
   {"fluid_type":"Transmission","specification":"DEXRON ULV","capacity":null,"unit":"L (not listed)",
    "source":"2023 Chevrolet Tahoe OM","page":"403","grade":"A","verification_status":"Verified"},
   {"fluid_type":"Brake","specification":null,"capacity":null,"unit":null,
    "source":null,"grade":null,"verification_status":"Not Verified"}
  ]}
```

## 5. Frontend Display States (mandatory behaviours)
| State | Trigger | UI behaviour |
|-------|---------|--------------|
| **Complete Grade-A** | all core fields Verified, grade A | Show full card with "Official ✓" + source badges |
| **Partial Grade-A** | some fields Verified, others Not Verified | Show verified fields; render missing as "Not yet verified" (greyed) — never blank-implying-zero |
| **Market confirmation required** | `>1` market record & confidence < 0.7 | Block specs; show "Is this US-import or GCC?" chooser (+ VIN/odometer helpers) |
| **Official source blocked** | source exists, status Blocked_OCR/Login | Show "Official data exists — verification pending" (amber), with no values |
| **Data unavailable** | no official source found | Show "No official data yet" (grey); offer "request this vehicle" |
| **EV vehicle** | engine.fuel_type=Electric | Hide engine-oil/spark fields entirely; show EV set (HV-battery coolant, reduction-gear, 12V, brake fluid, cabin filter, HV warranty) |
| **Hybrid vehicle** | fuel_type Hybrid/PHEV | Show engine fields + hybrid-specific (inverter coolant) where official; flag dual-loop coolant |

**Hard rule across all states:** a field is shown as a *value* only if `verification_status='Verified'` AND `grade='A'`. Anything else renders as a status, not a number.

## 6. Error/empty semantics
- Missing official value → field present with `value:null, verification_status:"Not Verified"` (the app shows "—", not a guess).
- Blocked official → `verification_status` ∈ {Blocked_OCR, Blocked_Login, Verification_Pending}.
- The API never returns a numeric value without `source` + `grade` + `verification_status`. (Enforced by the QA gates.)
