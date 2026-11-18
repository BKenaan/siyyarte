# OEM maintenance schedules — Japanese makes, set 2: sources & coverage

Companion to `oem_schedules_japanese2.dart`, covering the Japanese makes NOT in
`oem_schedules_japanese.dart`: **Suzuki, Mazda, Subaru, Isuzu, Daihatsu**. Every
interval in that file is traceable to one of the sources below, read from an
actual document. This mirrors the `verified_specs` discipline
(`data_backend/README.md`): **incomplete coverage is fine; an unverified
displayed value is not.** Nothing was inferred, guessed, or copied across models
or makes. Where no trustworthy source was reachable, the item is listed as a
**gap**, not filled in.

Grades: **A** = read directly/unambiguously from a manufacturer / official
importer maintenance document. **B** = official content but market/engine-column
dependent, from a footnote, or from a faithful third-party reproduction of the
OEM owner's manual (used only where the manufacturer's own host was
unreachable). **C** = figure only positionally implied by the source.

---

## Sources used

### Suzuki

1. **Suzuki Australia (official) — "Genuine Servicing: FAQ" service-interval table** (Grade A)
   `https://www.suzuki.com.au/owners/genuineservicing/frequently-asked-questions`
   Backs the CURRENT-range service interval (which bundles the engine-oil
   change): **non-turbo 15,000 km / 12 mo** (Swift 1.2, Baleno 1.4, Vitara 1.6,
   Jimny 1.5, Ignis 1.2); **turbo 10,000 km / 12 mo** (Swift 1.0, Swift Sport
   1.4, Vitara 1.4, S-Cross 1.4). The FAQ publishes only this overall interval —
   **no per-item fluid/plug intervals** — so only the service/oil interval is
   recorded for the current range.

2. **Suzuki Grand Vitara Owner's Manual — "Periodic Maintenance Schedule" (2010–11 MY)** (Grade B)
   `https://www.manualsdir.com/manuals/153941/suzuki-2010-grand-vitara.html?page=252`
   (and `...?page=253`) — read from a faithful owner's-manual reproduction
   because Suzuki's own portals (suzuki.com.au owner manuals, suzukiauto.co.za)
   and ManualsLib are Cloudflare-gated (confirmed 403). This is a **legacy**
   model, recorded as a genuine Suzuki per-item reference and **labelled as
   such — NOT asserted for the current Swift/Vitara/Jimny.** Backs: engine oil &
   filter every 12,500 km (month cell unreadable, omitted); spark plugs
   100,000 km / 60 mo (again at 200,000 km); air cleaner element every
   50,000 km; coolant (genuine blue long-life) first 150,000 km / 90 mo then
   75,000 km / 45 mo; coolant (green, if non-genuine) every 50,000 km / 30 mo.

### Mazda

3. **Mazda North American Operations — "2020 CX-5 Scheduled Maintenance" owner-guide PDF** (Grade A; Mexico-table items Grade B)
   `https://www.mazdausa.com/siteassets/global-resources/vehicle-resources/owner-manuals/2020/cx-5/2020-cx-5-scheduled-maintenance.pdf`
   Official Mazda USA guide, read page-by-page. Carries U.S./Canada tables (km +
   mi) and a Mexico table (pure km) with an explicit normal (Schedule 1) /
   severe (Schedule 2) split. Backs CX-5 (2nd-gen KF), SKYACTIV-G petrol:
   - **Oil & filter** — condition-based "Flexible Maintenance" (default U.S./PR);
     fixed-maximum baseline **12,000 km / 12 mo**. Severe (Mexico Schedule 2)
     **5,000 km / 3 mo** (Grade B, Mexico table).
   - **Spark plugs** — NA 2.0/2.5 **120,000 km**; 2.5 Turbo **64,000 km**.
   - **Air filter** — **56,000 km / 3 yr** (Canada table, explicit statement).
   - **Cabin filter** — **48,000 km / 2 yr** (U.S./Canada severe table).
   - **Coolant (FL-22)** — first **192,000 km / 10 yr**, then **96,000 km / 5 yr**.
   - **Brake fluid** — **40,000 km / 24 mo** (Mexico table, R at 40/80/120k;
     Grade B — the U.S./Canada petrol table only *inspects* fluid level).
   The diesel SKYACTIV-D 2.2 rows were deliberately NOT recorded (Lebanon bans
   diesel passenger cars). NOT copied to Mazda 2/3/6, CX-3, CX-30 or CX-9.

### Subaru

4. **Subaru of America — "2022 Warranty & Maintenance Booklet" (rev. Nov 2021)** (Grade A)
   `https://techinfo.subaru.com/stis/doc/warrantyBooklet/2022_war_and_maint_120721.PDF`
   Official SOA booklet, p.28 **"2022 MY All Vehicles — Federal/California"**
   schedule + p.29 severe-conditions Notes. Make-wide (covers Impreza, Forester,
   Outback, Crosstrek/XV; BRZ/WRX/Hybrid exceptions noted on the table). km
   values are the exact-conversion km row printed beside the mile columns.
   Backs: oil & filter 9,600 km / 6 mo (severe 4,800 km / 3 mo, Note 1); spark
   plugs 96,000 km / 60 mo; air filter 48,000 km / 30 mo (dust: inspect more
   often, Note 8); cabin A/C filter 19,200 km / 12 mo; coolant first 220,000 km
   / 11 yr then 120,000 km / 6 yr; brake fluid 48,000 km / 30 mo (severe
   24,000 km / 15 mo, Note 5); CVT fluid — normal inspect only, severe replace
   40,000 km (Note 4); front/rear diff gear oil — normal inspect only, severe
   24,000 km / 15 mo (Note 3); fuel filter single replacement 115,200 km / 72 mo.

---

## Coverage summary (what was sourced)

| Make | Models/engines sourced | Normal | Severe |
|------|------------------------|:------:|:------:|
| Suzuki | Current range service interval (NA 15k / turbo 10k km); Grand Vitara per-item (legacy ref) | ✓ | — |
| Mazda | CX-5 (KF) SKYACTIV-G petrol | ✓ | ✓ |
| Subaru | Make-wide 2022 MY (Impreza/Forester/Outback/Crosstrek…) | ✓ | ✓ |
| **Isuzu** | **none — diesel-only, excluded for Lebanon** | — | — |
| **Daihatsu** | **none — no OEM document reachable** | — | — |

---

## Gaps (honest, un-padded)

- **Isuzu — deliberate exclusion, not a failure.** The D-Max and MU-X are
  **diesel-only** across every current engine — 1.9 L RZ4E-TC, 2.2 L RZ4F and
  3.0 L 4JJ3 are all turbo-diesels, with no petrol passenger variant in the
  sourced markets (CarExpert/4x4 Australia engine coverage,
  `https://carexpert.com.au/car-news/isuzu-d-max-gets-1-9-litre-diesel-option`;
  `https://www.4x4australia.com.au/reviews/2022-isuzu-d-max-sx-1-9-4x2-review`).
  Lebanon bans diesel passenger cars, so there is nothing petrol to record.

- **Daihatsu — complete gap.** No official Daihatsu maintenance **document** was
  reachable. Terios/Gran Max intervals surfaced only via Indonesian secondary
  news — e.g. an Astra-Daihatsu product-executive quote that the facelift Gran
  Max moved the spark-plug interval from 20,000 km to 100,000 km
  (`https://otomotifnet.gridoto.com/read/233456728/`), and dealer cost tables
  listing 10,000-km service steps. None is a fetched OEM schedule, so per the
  GOLDEN RULE nothing was recorded. **Action:** obtain a Daihatsu owner's-manual
  maintenance page or Astra-Daihatsu service booklet (Indonesia) or a Perodua
  equivalent.

- **Suzuki per-item fluids for the CURRENT range — partial.** Suzuki Australia's
  FAQ gives the current models' service/oil interval (15k NA / 10k turbo) but no
  per-item plug/coolant/brake intervals, and the current Swift/Vitara/Jimny/
  Baleno/Dzire/Ertiga/Ciaz owner's manuals were only on Cloudflare-gated hosts
  (suzuki.com.au owner manuals, ManualsLib — both 403). The per-item figures
  recorded are from the **legacy Grand Vitara** manual and are labelled as such;
  they are **not** asserted for current models. **Action:** obtain a current
  Suzuki owner's-manual Periodic Maintenance Schedule (or a Maruti Suzuki
  equivalent for Swift/Dzire/Baleno/Ertiga/Ciaz) from a non-Cloudflare host or
  by manual upload.

- **Mazda other models — not covered.** Only the CX-5 (KF) was sourced from a
  clean official document. Mazda 2/3/6, CX-3, CX-30 and CX-9 were NOT captured
  and their CX-5 figures were **not** copied across. Mazda publishes per-model
  scheduled-maintenance PDFs at the same `mazdausa.com/siteassets/.../owner-manuals/<year>/<model>/`
  path and per-model tables at `owners-manual.mazda.com/gen/en/<model>/...`;
  **action:** fetch those per model. (Mazda's `owners-manual.mazda.com` HTML
  renders the schedule across many per-item sub-pages, so the PDF route is
  faster.)

- **Subaru model-specific / turbo tables — partial.** The recorded schedule is
  the make-wide 2022 MY table; it notes BRZ/WRX/Hybrid exceptions only where the
  booklet itself does. Turbo (WRX/Ascent 2.4T) model-specific plug/fluid
  intervals, and the newer FA24 turbo range, were not separately captured.
  **Action:** source the per-model MY2023+ booklets (same techinfo.subaru.com
  path) if turbo-specific figures are needed.

- **General:** figures published only in miles (Subaru) use the km row printed
  beside the mile columns (exact conversions). Where a cell could not be read
  unambiguously (e.g. the Suzuki Grand Vitara oil month cell, the Mazda petrol
  fuel-filter engine scope) the value was omitted rather than guessed.
