# Siyyarte — Frontend Display-State Test Cases (beta)

The app must never show a guessed value. Each case below is a fixture the frontend must pass.

| # | Scenario | Vehicle fixture | API state | Expected UI |
|---|----------|-----------------|-----------|-------------|
| TC-1 | **Complete vehicle** | Chevrolet Tahoe 2023 5.3L (NA) | all core fluids + intervals Verified_A | Full card; every value with "Official ✓" + source/page badge |
| TC-2 | **Partial — capacity blocked** | Kia Rio SC (GCC) | oil **spec** Verified_A; oil/coolant/tank **Not Verified** (capacities render-blocked) | Show oil grade; render capacities as "Official source — verification pending" (amber), NOT blank/0 |
| TC-3 | **Partial — engine only** | Mitsubishi L200 4N16 (GCC) | engine identity Verified_A; fluids Not Verified | Show engine/identity; fluids section shows "Official data not yet available" |
| TC-4 | **Market confirmation required** | Ford Explorer 2022 (user in Lebanon) | model has NA record; GCC unknown; routing confidence < 0.7 | Block specs; prompt: "Is your car US-import, GCC-spec, European, or unknown?" + odometer/VIN helpers |
| TC-5 | **Market resolved by decisive clue** | Tahoe, user states "imported from USA" | routing confidence ≥ 0.9 (decisive) | Serve NA record directly; show "US-spec" market badge |
| TC-6 | **Blocked — official source exists** | BYD Atto 3 (GCC) | source registered; status Blocked_OCR | "Official manual located — extraction pending" (amber); no values shown |
| TC-7 | **Unavailable — no official source** | Changan model | no official manual | "No official data yet" (grey) + "Request this vehicle" CTA |
| TC-8 | **EV vehicle** | BYD Atto 3 (when extracted) | fuel_type=Electric | Hide engine-oil/spark fields entirely; show EV set (HV-battery coolant, reduction gear, 12V, brake fluid, cabin filter, HV warranty) |
| TC-9 | **Hybrid vehicle** | Toyota Corolla HEV / MG HS Hybrid | fuel_type Hybrid | Show engine fields + hybrid-specific (inverter coolant) where official; flag dual-loop coolant |
| TC-10 | **GCC vs EU provenance guard** | Hyundai Tucson (GCC) | source en_GN (Gulf Nations), ME oil grade | Show GCC card; a EU/`/main`-sourced value would be rejected by QA12 and never render |
| TC-11 | **Severe-service (Lebanon)** | Corolla GCC | maintenance has normal+severe; Lebanon=severe | Default to severe column; label "Lebanon: severe-service schedule" |
| TC-12 | **Field with value but no unit (must never happen)** | any | QA9 blocks at ingest | N/A — gate prevents shipping; if seen, show error state, not the number |

**Global assertions (every screen):**
- A number renders only if `verification_status='Verified'` AND `grade='A'`. Else → status chip.
- Every shown value links to its source document + page.
- Market badge always visible; mismatched-market values never blended.
