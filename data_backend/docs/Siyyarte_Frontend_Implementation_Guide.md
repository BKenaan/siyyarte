# Siyyarte — Frontend Display-State Implementation Guide (beta)

Implements the 7 states; fixtures in `Siyyarte_Display_State_Test_Cases.md` are the acceptance tests.

## State machine (per vehicle screen)
1. Resolve market (call `/route-market`). If `confidence < 0.7` → **State 3: Market Confirmation** (ask US/GCC/EU/unknown + odometer + VIN + import source). Do not proceed.
2. Fetch fluids + maintenance.
3. Compute completeness from `available_fields` vs `missing_fields`:
   - all core present → **State 1: Complete** (full card, source badges).
   - some present → **State 2: Partial** (verified values + labelled gaps).
4. For each missing field, label by reason: `Not Verified` → "Verification pending"; source status `Blocked_OCR` → "Official source located, extraction pending"; `Blocked_Login` → same; no source → **State 5: Unavailable** "Official source not yet available".
5. If `fuel_type=Electric` → **State 6: EV** (hide engine-oil/spark; show EV set). If Hybrid → **State 7: Hybrid** (engine + hybrid fields).

## Hard rules
- **Never** render `0 L`, `N/A`, `—` *as if it were data*, or any estimated/generic value. Missing = a labelled status chip.
- Every numeric value shows a tappable source (document + page).
- Market badge always visible.
- A field with `verification_status != 'Verified'` or `grade != 'A'` is **non-renderable as a number** at the component level (enforce in the value component, not just the screen).

## Component contract
`<SpecValue value grade status source page />` → renders the number only if `status==='Verified' && grade==='A'`; otherwise renders the matching status chip. This makes "no guessed value" a property of the smallest unit, not a screen-level promise.
