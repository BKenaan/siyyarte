# OEM Maintenance Schedule Sources — additional European & American makes

Companion to `oem_schedules_euro_american_extra.dart`. Every interval in that
file cites one of the `source` keys below. This document gives the full
provenance (document, publisher, URL, what it is) and, honestly, the **gaps**
that could not be sourced from an opened OEM document and were therefore omitted.

Research date: 2026-11-18. Golden rule observed: **no unverified number was
written** — anything not backed by an opened document here was left out, not
guessed, and nothing was copied across models/makes.

Units note: the Stellantis / MINI / Volvo / Land Rover documents publish in
**miles**; the Dart file stores **kilometres**, converted at the repo's standard
×1.6 factor (10k mi = 16,000 km, 60k mi = 96,000 km, 100k mi = 160,000 km,
150k mi = 240,000 km), matching `verified_specs.json` and the sibling corpora.
Where a document printed a round km value itself (e.g. the Mopar cabin filter
"12,000 miles (19,000 km)"), that km value is stored verbatim. The **Peugeot
plan d'entretien** sheets publish in **kilometres natively**, so their values are
stored verbatim with no conversion.

Method note: the Mopar / Volvo maintenance schedules are **X-mark grid tables**.
Plain text extraction destroys the column alignment, so each table page was
**rendered to an image and read visually** to place every X in its correct
mileage column. Prose caps (oil, coolant) were cross-checked against the
extracted text.

---

## Stellantis — Jeep / Dodge / RAM (US-market Mopar owner manuals)

**Service system:** the **oil** item is governed by the **Oil Change Indicator
System** (`conditionBased: true`) with a hard cap read verbatim from every book:
*"Under no circumstances should oil change intervals exceed 10,000 miles
(16,000 km), 12 months or 350 hours of engine run time, whichever comes first."*
The **rest** of the plan is a **fixed X-mark mileage table** (Grade A). Spark-plug
rows carry the footnote *"The spark plug change interval is mileage-based only;
yearly intervals do not apply."*

**Important Stellantis structural facts (why some items are omitted):**
- These Mopar plans publish **no brake-fluid replacement interval** — brake fluid
  only appears under "at every oil change: inspect brake pads/hoses/fluid level".
  So brake fluid is a **gap** for all Jeep/Dodge/RAM rows (not invented).
- They publish **no normal automatic-transmission-fluid interval** (the 8-/9-speed
  autos are "fill-for-life"). Only **severe** driveline items (transfer case /
  axle / manual-trans fluid for police/taxi/fleet/off-road/towing) are scheduled,
  and those are captured as `OemSeverity.severe`. Lebanon = severe, so they apply.

| `source` key | Document | Publisher | URL |
|---|---|---|---|
| `RAM 1500 2022 Owner Manual (Mopar US)` | 2022 RAM 1500 (DT) Owner's Manual, pp. 403–406 | Stellantis / Mopar (US) | https://vehicleinfo.mopar.com/assets/publications/en-us/Ram/2022/1500_DT/P132845_22_DT_OM_EN_USC_DIGITAL.pdf |
| `Dodge Charger 2023 Owner Manual (Mopar US)` | 2023 Dodge Charger (LD) Owner's Manual, p. 208 (3.6L & 5.7L plan) | Stellantis / Mopar (US) | https://vehicleinfo.mopar.com/assets/publications/en-us/Dodge/2023/Charger/5735565_23_LD_OM_EN_USC_DIGITAL_E3.pdf |
| `Dodge Durango 2020 Owner Manual (Mopar US)` | 2020 Dodge Durango (WD) Owner's Manual, p. 226 (Non-SRT plan) | Stellantis / Mopar (US) | https://vehicleinfo.mopar.com/assets/publications/en-us/Dodge/2020/Durango/P136150_20_WD_OM_EN_USC_DIGITAL.pdf |
| `Jeep Grand Cherokee 2021 Owner Manual (Mopar US)` | 2021 Jeep Grand Cherokee (WK) Owner's Manual, pp. 318–320 | Stellantis / Mopar (US) | https://vehicleinfo.mopar.com/assets/publications/en-us/Jeep/2021/Grand_Cherokee/P135632_21_WK_OM_EN_USC_DIGITAL.pdf |
| `Jeep Wrangler 2023 Owner Manual (Mopar US)` | 2023 Jeep Wrangler (JL) Owner's Manual, pp. 296–297 | Stellantis / Mopar (US) | https://vehicleinfo.mopar.com/assets/publications/en-us/Jeep/2023/Wrangler/5690673_23_JL_OM_EN_USC_DIGITAL_E3.pdf |
| `Jeep Compass 2023 Owner Manual (Mopar US)` | 2023 Jeep Compass (MP) Owner's Manual, p. 211 | Stellantis / Mopar (US) | https://vehicleinfo.mopar.com/assets/publications/en-us/Jeep/2023/Compass/5662345_23_MP_OM_EN_USC_DIGITAL_E4.pdf |
| `Jeep Cherokee 2020 Owner Manual (Mopar US)` | 2020 Jeep Cherokee (KL) Owner's Manual, pp. 328–329 | Stellantis / Mopar (US) | https://msmownerassets.z13.web.core.windows.net/assets/publications/en-us/Jeep/2020/Cherokee/P115188_20_KL_OM_EN_USC_DIGITAL.pdf |

**Backs (read from the rendered table pages, Grade A):**
- **RAM 1500** (3.6L V6 eTorque / 5.7L V8 HEMI): oil 10k mi/12 mo cap; spark plugs
  100,000 mi; engine air cleaner 30,000 mi; cabin filter **"every 12,000 miles
  (19,000 km)"** (verbatim); coolant 10 yr / 150,000 mi; transfer-case fluid
  (severe tow/fleet) by 120,000 mi; evaporative fresh-air (fuel-vapor) filter
  severe-dusty every 10,000 mi.
- **Dodge Charger** (3.6L / 5.7L): oil cap; spark plugs 100,000 mi; engine air
  cleaner 30,000 mi; cabin filter 12,000 mi (19,000 km); coolant 10 yr/150,000 mi;
  AWD transfer-case fluid (severe) 60k/120k.
- **Dodge Durango** (3.6L / 5.7L, Non-SRT): oil cap; spark plugs 100,000 mi;
  engine air filter 30,000 mi; **A/C (cabin) filter 20,000 mi**; coolant
  10 yr/150,000 mi; accessory drive belt 150,000 mi; axle fluid (severe) 40,000 mi.
- **Jeep Grand Cherokee (WK)** (3.6L / 5.7L): oil cap; spark plugs 100,000 mi;
  engine air cleaner 30,000 mi; **cabin filter 20,000 mi**; coolant 10 yr/150,000 mi.
- **Jeep Wrangler (JL)**: oil cap; **spark plugs 2.0L Turbo 60,000 mi, 3.6L V6
  100,000 mi** (two separate rows in the book); engine air cleaner 30,000 mi;
  cabin filter 12,000 mi (19,000 km); coolant 10 yr/150,000 mi; transfer-case &
  axle fluid (severe) 60k/120k and 40k.
- **Jeep Compass (MP)** (2.0L Turbo): oil cap; **spark plugs 60,000 mi**; engine
  air cleaner 30,000 mi; cabin filter 12,000 mi (19,000 km); coolant 10 yr/150,000 mi.
- **Jeep Cherokee (KL)**: oil cap; **spark plugs 2.0L Turbo 60,000 mi, 2.4L & 3.2L
  100,000 mi** (two separate rows); engine air cleaner 30,000 mi; A/C/cabin filter
  20,000 mi; coolant 10 yr/150,000 mi.

**Note on cabin-filter divergence** (not an error): the Mopar books genuinely print
different cabin-filter intervals per platform — **12,000 mi** on RAM 1500 / Charger /
Wrangler / Compass, **20,000 mi** on Grand Cherokee / Durango / Cherokee. Each value
was read from that model's own table; none copied across.

**Stellantis gaps (omitted, not guessed):** brake-fluid replacement (not scheduled
by Mopar — inspect only); normal automatic-transmission-fluid change (fill-for-life).
RAM **diesel** (3.0L EcoDiesel) schedule was not captured — diesel is banned for
Lebanese passenger cars anyway.

---

## MINI — Condition Based Service (official MINI USA maintenance booklet)

**Service system:** CBS, like BMW (`conditionBased: true`). The booklet ties each
item to a specific **engine-oil-service count** and gives the approximate mileage.

- **`MINI MY2025 / 2022 Maintenance Booklet (MINI USA)`**
  - Documents: *MINI MY2025 All-Models Maintenance* and *2022 MINI Maintenance*,
    MINI USA (BMW Group).
  - URLs:
    - https://minipub-prod.bmwgroup.com/content/dam/mini/PDF/warranties/MINI_MY2025_All_Models_Maintenance_2025-03-07_1K.pdf
    - https://minipub-prod.bmwgroup.com/content/dam/mini/PDF/warranties/2022_MINI_Maintenance.pdf
  - Backs (read verbatim from both editions, Grade A unless noted):
    - Engine oil & filter — "As specified by CBS"; CBS illustration shows a
      ~10,000 mi oil service → stored 16,000 km baseline (**Grade B** for the
      number, conditionBased).
    - Spark plugs (**all models**) — *"At every 6th Engine Oil Service: Spark
      plugs: Replace (approximately 60,000 miles)"* → 96,000 km.
    - Engine air filter / intake air cleaner — *"At every 4th Engine Oil Service
      ... (approximately 40,000 miles)"* → 64,000 km; *"reduce replacement
      interval in dusty operating conditions"* (severe note, no separate number).
    - Cabin microfilter — *"At every 2nd Engine Oil Service"* → ~20,000 mi /
      32,000 km.
    - Oxygen sensor — 150,000 mi (all models).
  - Brake fluid — *"Replace brake fluid (as shown in CBS)"*, tracked by **date**;
    the booklet prints **no fixed months/mileage**, so **no number recorded**
    (BMW-group CBS brake fluid is conventionally ~2 yr, but that figure is not in
    this document → honest gap).

**MINI gaps:** engine **coolant** is "check level and concentration" only
(long-life, no replacement interval published) — **omitted**. Brake-fluid time
figure — **omitted** (CBS date only). Transmission oil — not in the booklet
(BMW-group autos marketed "lifetime") — **omitted**.

---

## Volvo — official Factory Scheduled Maintenance sheet

**Service system:** fixed Service Reminder Indicator, **10,000 mi / 1 yr**, then a
fixed-mileage table for longer items. All **Grade A** — read from the official
sheet. Marked `conditionBased: true` only because the SRI drives the display; the
figures themselves are a hard table.

- **`Volvo 2025 Factory Scheduled Maintenance (PHEV/MHEV)`**
  - Document: *Schedule of Factory Maintenance Service Operations — 2025 PHEV/MHEV
    Models (S60, S90, V60, V60CC, V90, V90CC, XC40, XC60, XC90)*, MY25 edition
    (footer "MY25 6.26"), source line: *Volvo Warranty and Service Records
    Information*. Volvo Car USA.
  - URL: https://azure-eu-assets.contentstack.com/v3/assets/bltccbab8edae0354cd/blt1f1676a16c88494e/6a29cb4fc1351a105b5ed89d/2025_FSM_Maintenance_Sheets_PHEV_MHEV_6.8.26.pdf
  - Covers the priority Lebanon models XC40, XC60, XC90, S60, S90 (B5/B6 mild-
    hybrid petrol + T8 PHEV).
  - Backs (exact wording):
    - Engine oil & filter — *"Every 10,000 miles or 1 year, whichever comes
      first"* (full-synthetic ACEA A5/B5).
    - Brake fluid — *"Replace Every 3 Years"*; **severe**: *"if driven in
      mountainous areas or humid climates — every year"*.
    - Cabin air filter — *"Every 20,000 Miles"* (section), note *"at least once a
      year or more often in heavy traffic and dirty/dusty areas"* (severe).
    - Engine air cleaner (ACL) filter — *"Every 40,000 Miles"*; *"may be necessary
      to change more frequently when driving in dusty/dirty areas"* (severe).
    - Spark plugs — *"Every 60,000 Miles"*.
    - Accessory drive belt — *replace at 80,000 mi*; belt tensioner + idler pulley
      at 150,000 mi.
    - Timing belt, tensioner & idler pulley — *"Replace at 150,000 miles or
      10 years, whichever comes first"* (Volvo VEA engines use a **wet timing
      belt** — a genuine replacement item). Water-pump belt shares 150,000 mi /
      10 yr.

**Volvo gaps:** engine **coolant** — the sheet lists *"Check/Adjust Antifreeze
Rating and Anti-Corrosion Agent"* only, with **no replacement interval** (Volvo
long-life coolant) — **omitted**. **Automatic transmission fluid** — *"Check for
Leaks/Adjust"* only (lifetime fill) — **omitted**.

---

## Land Rover — owner's handbook "Maintenance" section (JLR Topix)

**Service system:** variable **Service Interval Indicator** — the display shows
either distance-to-service or days-remaining, so **no single fixed odometer figure
is published** for the oil/service item (`conditionBased: true`, number omitted).

- **`Land Rover Owner Handbook — Maintenance (JLR Topix)`**
  - Document: *Land Rover Owner's Handbook — Maintenance* section (Range Rover era
    owner-maintenance guide), Jaguar Land Rover, hosted on the official JLR Topix
    service portal.
  - URL: https://topix.landrover.jlrext.com/topix/service/archive/64263/maintenance.pdf
  - Backs:
    - Engine coolant — *"completely renewed every ten years, regardless of
      distance"* (anti-corrosion checked once a year) — **Grade A**, read verbatim.
    - Brake fluid — the handbook states the change is **time-based** and recorded
      in the Passport to Service; it does not print the number in this section.
      The concrete figure — **every 3 years** (Range Rover / Sport / Discovery /
      Evoque) — is corroborated across the JLR owner-guide family (**Grade B**).
      **Defender exception: every 2 years / 24,000 mi (40,000 km)** — captured as a
      separate row that also serves the severe end.
  - Severe: the handbook's *"Driving in arduous conditions"* note says "more
    frequent attention must be paid to servicing requirements" (Lebanon = arduous).

**Land Rover gaps (omitted):** oil/service **distance** interval (variable SII, no
fixed number published); **spark plugs**, **engine air filter**, **pollen/cabin
filter** (these live in the model-specific *Passport to Service* / Maintenance
Check Sheet, which was not openable). Not guessed.

## Peugeot — PureTech petrol (official "plan d'entretien", forum-mirrored)

**Service system:** PSA's EB2 "PureTech" plan publishes a **fixed normal/severe
km+time table** (`conditionBased: false`). The owner picks the *normal* or
*séverisé* plan at purchase; an on-board service indicator (*témoin*) can only
bring a service **forward**. Each sheet carries the genuine Peugeot **B71** oil
specs and PSA's own severe-use definition (*"taxi/ambulance, urban < 20 km/h,
repeated short cold trips < 10 km, dusty countries"*), confirming it is the real
Peugeot plan — but each is a **Microsoft-Word reproduction hosted on the
forum-peugeot.com enthusiast site, not fetched from a Peugeot-owned host**, so
every value is graded **B** with that caveat recorded in the Dart `notes`.

**Why not copied across models:** the three sheets were read individually (via
`pdftotext -table`) and the intervals genuinely **differ** — 208 oil 20,000 km vs
2008/5008 25,000 km; 208 plugs/air 40,000 km vs 2008/5008 50,000 km; 208 cabin
20,000 km/1 yr vs 5008 50,000 km/2 yr; 5008 *severe* plugs 30,000 km vs 2008
*severe* plugs 45,000 km. A reproduction could not have invented three distinct,
internally-consistent engine plans, which corroborates authenticity.

| `source` key | Document | Publisher (reproduced on) | URL |
|---|---|---|---|
| `Peugeot 208 1.2 PureTech Plan d'Entretien (forum-peugeot)` | "208 (P21E) – INJECTION 1.2 PURETECH 100 S&S BVM6 – PLAN D'ENTRETIEN" and the identical "…130 S&S EAT8" sheet | Peugeot (PSA), via forum-peugeot.com | https://www.forum-peugeot.com/wp-content/uploads/2020/05/planentretien208puretech100bvm.pdf · https://www.forum-peugeot.com/wp-content/uploads/2020/05/planentretien208puretech130.pdf |
| `Peugeot 2008 1.2 PureTech 82 Plan d'Entretien (forum-peugeot)` | "2008 – INJECTION 1.2 PURETECH 82 BVM5 – PLAN D'ENTRETIEN" | Peugeot (PSA), via forum-peugeot.com | https://www.forum-peugeot.com/wp-content/uploads/2016/06/planentretien2008puretech82.pdf |
| `Peugeot 5008 1.2 PureTech 130 Plan d'Entretien (forum-peugeot)` | "5008 (P87) – INJECTION 1.2 PURETECH 130 S&S BVM6 – PLAN D'ENTRETIEN" | Peugeot (PSA), via forum-peugeot.com | https://www.forum-peugeot.com/wp-content/uploads/2017/03/planentretien5008puretech130bvm6.pdf |

**Backs (read verbatim from each sheet's normal | severe columns, Grade B):**
- **208** (PureTech 100 BVM6 / 130 EAT8, identical): oil 20,000 km/1 yr | 15,000/1;
  cabin filter 20,000/1 | 15,000/1; brake fluid 2 yr (both); air filter 40,000/4 |
  30,000/4; spark plugs 40,000/4 | 30,000/4; timing belt (courroie de distribution)
  100,000 km/6 yr then 200,000/12 | 105,000/6 then 210,000/12; coolant replace
  180,000 km/10 yr | 165,000/10 (pH check 120,000/4 then yearly).
- **2008** (PureTech 82 BVM5): oil 25,000/1 | 15,000/1; cabin filter 25,000/2 |
  15,000/1; brake fluid 2 yr; air filter 50,000/4 | 45,000/4; spark plugs 50,000/4 |
  45,000/4; timing-belt kit 175,000 km/10 yr | 165,000/10. **Coolant gap:** this
  sheet prints only a pH check (125,000/4 then yearly), no replacement line → omitted.
- **5008** (PureTech 130 BVM6): oil 25,000/1 | 15,000/1; cabin filter 50,000/2 |
  15,000/1; brake fluid 2 yr; air filter 50,000/4 | 45,000/4; spark plugs 50,000/4 |
  **30,000/4 severe**; timing belt 100,000 km/6 yr then 200,000/12 | 105,000/6 then
  210,000/12. **Coolant gap:** only a pH check (125,000/4 then every 25,000 km) →
  omitted. Wet-belt note: Peugeot later shortened PureTech belt intervals via
  service campaigns; the stored figures are the plan-sheet values as printed.

---

## Honest GAPS — makes/models NOT recorded (no OEM document opened)

The GOLDEN RULE forced these out rather than filling them with secondary or
conflicting figures. Each was searched; none yielded an openable, model-specific
**manufacturer** maintenance table.

- **Jaguar — F-Pace / XE / XF.** Confirmed Jaguar uses a **variable Service
  Interval Indicator** (the XJ Owner's Handbook, Publication JJM 10 02 21 802 on
  jaguar.fr/content/dam, §"Service interval indicator", prints the indicator
  mechanism but **no fixed interval table** — the same regime as Land Rover). The
  concrete F-Pace schedule lives behind VIN navigation on ownerinfo.jaguar.com
  (iGuide) and in the model-specific Passport to Service; the topix.jaguar.jlrext.com
  service-procedure PDFs are scanned JPEG-2000 images (not text-extractable here).
  jaguarusa.com/owners/service-warranties/servicing 301-redirects to the home page.
  Only complimentary-maintenance coverage (5 yr / 60,000 mi) and third-party (KBB)
  figures (service ~16,000 mi, plugs ~32,000 mi) were found — **not OEM**, so
  **omitted**, and NOT copied from the Land Rover handbook (different make). No
  single fixed odometer figure is published → honest gap (as with Land Rover).
- **Škoda — Octavia / Kodiaq / Superb.** Only secondary sources (Haynes,
  CompleteCar, forums) and dealer fixed-price-plan brochures (no interval table).
  The official interval table lives in the owner's manual "Service Intervals"
  section (VW-group fixed vs. variable/LongLife), which was not openable from an
  official host. Consistent secondary figures (oil 15,000 km/1 yr fixed; plugs
  60,000 km/4 yr; brake fluid first 3 yr then 2 yr) exist but are **not OEM
  documents** → **omitted**.
- **SEAT — Leon / Ateca.** Same situation as Škoda (shared VW-group regime); no
  openable official interval table → **omitted**.
- **Peugeot — 208 / 2008 / 5008: NOW SOURCED** (Grade B) — see the Peugeot section
  above. **Still gaps: Peugeot 301 and 3008.** The 301 uses the older 1.2 VTi 72 /
  1.6 VTi 115 (no openable plan sheet found). For the **3008** every
  forum-peugeot.com PureTech plan link was dead (404) or the model page returned
  HTTP 403; only diesel (HDi/BlueHDi) 3008 sheets opened, which are out of scope
  (diesel banned). The 3008 PureTech sheet was NOT substituted from the 5008 sheet
  despite the shared engine, because the per-model tables proved to differ. →
  **omitted** for 301 and 3008.
- **Renault — Megane / Duster / Captur / Koleos / Symbol.** No official Renault
  maintenance schedule located; only third-party carnet aggregators (idgarages,
  piecesetpneus) with conflicting figures → **omitted**.
- **Citroën — C3 / C5 Aircross.** Shares PSA PureTech, but no Citroën-branded plan
  d'entretien was openable (Planète-Citroën / forum-citroen searches returned only
  third-party carnets and sales brochures). The Peugeot PureTech sheets were NOT
  copied across to Citroën (different make) → **omitted**.
- **Fiat — Tipo / 500.** These are EU-market models for Lebanon; no openable
  official Fiat maintenance table (the US Fiat 500 was discontinued 2019). Not
  copied from the Stellantis US (Jeep/Dodge/RAM) books — different models/engines.
  → **omitted**.

### Priorities that WERE fully sourced
**Grade A:** RAM 1500; Dodge Charger; Dodge Durango; Jeep Grand Cherokee; Jeep
Wrangler (both engines); Jeep Compass; Jeep Cherokee (all engines); MINI (all
models); Volvo (XC40/XC60/XC90/S60/S90 + V60/V90). Land Rover coolant (Grade A) +
brake fluid (Grade B).
**Grade B (official Peugeot plan d'entretien, forum-mirrored):** Peugeot 208
(PureTech 100 BVM6 / 130 EAT8), 2008 (PureTech 82 BVM5), 5008 (PureTech 130 BVM6)
— full normal + severe columns.
Everything else above is an honest, documented gap.
