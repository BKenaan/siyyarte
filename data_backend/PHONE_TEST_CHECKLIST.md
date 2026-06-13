# Phone test checklist — verified-specs layer (build 1.0.0+4)

Install: **https://garagi-prod.web.app/siyyarte-beta.apk** (installs over the previous build).
Sign in with your account. For each car: add it, open its detail screen, check the rows below.

> What "Verified" means here: a green **✓ Verified · GCC-spec / US-spec** badge that is **tappable** → opens the official source document + page. Computed rows show a grey **"General schedule — not manufacturer-verified for this car"** note. No row should ever show a number as verified without a tappable source.

| # | Add this car | Expect verified card? | Market badge | Specifically check |
|---|---|---|---|---|
| 1 | **Toyota Corolla**, year 2020 | ✅ Yes | **GCC-spec** | Verified card shows Engine Oil (5W-30 / 0W-16), Coolant (SLLC), CVT fluid, fuel tank 50 L, tyre 205/55R16, spark plug. Tap a badge → Toyota GCC Corolla Owner's Manual + page. |
| 2 | **Nissan Patrol**, ~2020 | ✅ Yes | **GCC-spec** | Verified fluids/attributes present; badges tappable to source. |
| 3 | **Hyundai Tucson**, ~2019 | ✅ Yes | **GCC-spec** | Verified specs shown; if it shows a "confirm your car's market" note, that's the GCC-vs-US routing working. |
| 4 | **Kia Sportage**, ~2019 | ✅ Yes | **GCC-spec** | Verified specs + citations. |
| 5 | **Ford F-150**, ~2022 | ✅ Yes | **US-spec** | Card should say **US-spec** (not GCC) — confirms market labelling differs from the GCC cars above. |
| 6 | **Chevrolet Tahoe**, ~2023 | ✅ Yes | **US-spec** | US-spec verified values (from phase2). |

## Cross-cutting checks (do these once)
- [ ] **Field-level, not screen-level:** on any verified car, rows *with* an official value show the green badge; rows *without* one (e.g. brake pads, tyres, suspension, battery for some models) still show the computed schedule with the grey "general schedule" note. The screen mixes both — it should never look 100% verified unless every row is.
- [ ] **Tap a Verified badge** → bottom sheet shows Source / Publisher / Page / Market / "Grade A" + a "View source document" button that opens the manufacturer PDF.
- [ ] **GCC vs US messaging:** GCC cars (1–4) say *GCC-spec*; US imports (5–6) say *US-spec*. If a model has both markets, you'll see a "values differ for US-import vs GCC — confirm your car's market" note.
- [ ] **No false verification:** scan for any number presented as official without a tappable source. There should be none.
- [ ] **Kia Rio (if you add one):** its Engine Oil & Brake should show as **pending / general**, NOT verified (those were demoted because the source was OCR-blocked).
- [ ] **An unsupported car** (e.g. a random older model not in the set): shows only the computed general schedule, clearly labelled — no verified card. This is expected.
- [ ] **GM/Ford excluded models** (Escalade, Silverado, Sierra, Suburban, Expedition, Edge): no verified card yet (see PHASE3_DATA_FIX_TICKET.md). Computed schedule only.

## If something's off
Note the car (make/model/year), the row, and what it showed vs expected. Most likely areas: market routing picking the wrong market, or an engine-variant mismatch (the verified card falls back to the first market match when the engine can't be inferred).
