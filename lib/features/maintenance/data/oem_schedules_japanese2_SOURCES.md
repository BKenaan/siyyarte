# OEM maintenance schedules — Japanese makes, set 2: sources & coverage

Companion to `oem_schedules_japanese2.dart`, covering the makes NOT in
`oem_schedules_japanese.dart`: **Suzuki, Mazda, Subaru, Isuzu, Daihatsu**, plus
(Round 2) **Acura** (Honda group) and **SsangYong / KGM** (petrol), and (Round 3)
a **Mitsubishi ASX** petrol entry completing the sibling file's sparser one. Every
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

### Mazda (additional models — Round 2)

5. **Mazda USA owner-guide "Scheduled Maintenance" PDFs** (Grade A; Mexico-only items Grade B)
   - Mazda3 (BP): `.../owners-optimized/2023/m3h/2023-mazda3-hatchback-scheduled-maintenance.pdf`
   - Mazda6 (GJ/GL): `.../owner-manuals/2020/mazda6/2020-mazda6-scheduled-maintenance.pdf`
   - CX-30 (DM): `.../owner-manuals/2020/cx-30/2020-cx-30-scheduled-maintenance.pdf`
   - CX-9 (TC): `.../owner-manuals/2019/cx-9/2019-cx9-scheduled-maintenance.pdf`
   - CX-3 (DK): `.../owner-manuals/2019/cx-3/2019-cx3-scheduled-maintenance.pdf`
   Each read page-by-page from the official Mazda USA PDF. All SKYACTIV-G petrol
   (diesel rows excluded). Common findings: spark plugs 120,000 km NA / 64,000 km
   2.5T (CX-9 is 2.5T→64k; CX-3/CX-30 NA→120k); coolant first 192,000 km / 10 yr
   then 96,000 km / 5 yr (FL-22); air filter 56,000 km / 3 yr (Canada statement);
   cabin filter 40–48,000 km / 24 mo (per model); brake fluid 40,000 km / 24 mo
   (Mexico table; CX-30 only had an electric-booster "every 2nd service" ≈24 mo).
   Oil is **condition-based** (Flexible Maintenance / vehicle status monitor):
   published max **12,000 km / 12 mo** (CX-5/6/9/3) or **16,000 km / 12 mo**
   (Mazda3/CX-30); severe **8,000 km / 6 mo** (16k models) or **5,000 km / 3 mo**
   (Mexico, 12k models).

### SsangYong / KGM (Round 2)

6. **KGM (SsangYong) Australia — official per-model petrol service schedules** (Grade A)
   - Rexton petrol (G20 GDi turbo): `https://kgm.com.au/owners-and-service/servicing/rexton-petrol`
   - Tivoli petrol (G16DF NA 1.6): `https://kgm.com.au/owners-and-service/servicing/tivoli-petrol`
   - Korando petrol (G15DTF turbo 1.5): `https://kgm.com.au/owners-and-service/servicing/korando-petrol`
   Base service 15,000 km / 12 mo (incl. oil). Coolant 200,000 km / 60 mo; brake
   fluid 24 mo; air filter 30,000 km / 24 mo; cabin filter every 2nd service
   (30,000 km). Spark plugs: NA Tivoli 120,000 km / 60 mo; turbo Rexton & Korando
   60,000 km / 48 mo (not cross-copied — turbo vs NA differ). ATF: Rexton 60,000
   km, Tivoli/Korando 100,000 km. KGM says severe conditions may need more
   frequent service but does not quantify (no severe column recorded). Diesel
   variants excluded (Lebanon).

### Acura (Honda group — Round 2)

7. **Acura MDX Owner's Manual — "Maintenance Minder" page (2008 MY)** (Grade B)
   `https://www.manualsdir.com/manuals/33002/acura-2008-mdx.html?page=396` (faithful
   mirror; Acura/Honda portals & ManualsLib are Cloudflare-gated). Acura's
   Maintenance Minder is **algorithmic/condition-based**: oil, filters, spark
   plugs, transmission fluid and coolant are called by the on-board Minder, with
   **no fixed OEM mileage table**. The manual prints fixed intervals only for:
   **brake fluid every 3 years** (independent of the Minder), and severe-use
   **rear differential fluid** first 12,000 km (7,500 mi) then every 24,000 km
   (15,000 mi). Only these two fixed values were recorded.

### Mitsubishi (Round 3 — OLX Lebanon scan)

8. **Mitsubishi Motors Australia — "23MY XD ASX Inspection and Maintenance Schedule" (v1.2)** (Grade A; CVT-normal & air-element omitted)
   `https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/23MY-XD-ASX-INSPECTION-AND-MAINTENANCE-SCHEDULE.pdf`
   Petrol (2.0/2.4 MIVEC), CVT. Base inspection 15,000 km / 12 mo (severe
   7,500 km / 6 mo). Backs: oil & filter 15,000 km / 12 mo (severe 7,500 km /
   6 mo); spark plugs 90,000 km / 72 mo; engine coolant first 165,000 km / 8 yr
   then 105,000 km / 5 yr (Super Long Life Coolant Premium); brake fluid
   30,000 km / 24 mo; cabin/air-purifier filter 15,000 km / 12 mo; CVT fluid
   severe "every 40,000 km". **Cross-file note:** the sibling
   `oem_schedules_japanese.dart` already carries a Mitsubishi **ASX (XD)** entry
   from the **24MY** schedule, but that one has only oil + CVT (its plug/coolant
   rows were "not legible"). This 23MY entry adds the spark-plug, coolant,
   brake-fluid and cabin-filter intervals the 24MY entry omits; the two overlap
   on oil & CVT. I could not edit the sibling file, so a maintainer should
   dedupe (prefer whichever is kept; the data agrees where both exist).

---

## Coverage summary (what was sourced)

| Make | Models/engines sourced | Normal | Severe |
|------|------------------------|:------:|:------:|
| Suzuki | Current range service interval (NA 15k / turbo 10k km); Grand Vitara per-item (legacy ref) | ✓ | — |
| Mazda | CX-5, Mazda3, Mazda6, CX-30, CX-9, CX-3 (SKYACTIV-G petrol) | ✓ | ✓ |
| Subaru | Make-wide 2022 MY (Impreza/Forester/Outback/Crosstrek/XV) | ✓ | ✓ |
| SsangYong/KGM | Rexton / Tivoli / Korando — petrol | ✓ | — |
| Acura | MDX — Maintenance Minder fixed items only (brake fluid, severe diff) | ✓ | partial |
| Mitsubishi | ASX / Outlander Sport (XD) petrol — 23MY (adds plugs/coolant/brake the sibling 24MY entry lacks) | ✓ | ✓ |
| **Isuzu** | **none — diesel-only, excluded for Lebanon** | — | — |
| **Daihatsu** | **none — no OEM document reachable** | — | — |
| **Mazda2** | **none — not sold in U.S.; no clean OEM doc fetched** | — | — |

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

- **Acura — Maintenance Minder (condition-based), only two fixed items.** Acura's
  main services (oil, filters, spark plugs, transmission fluid, coolant) are
  called by the algorithmic Maintenance Minder, so there is **no fixed OEM
  mileage table** to record for them — only brake fluid (3 yr) and severe-use
  rear diff fluid (first 12,000 km then 24,000 km) are fixed, and both were
  recorded. These were read from the 2008 MDX manual (current MDX/RDX/TLX
  manuals were Cloudflare-gated or image-only); they are **not** asserted as
  exact for RDX/TLX. **Action:** source current MDX/RDX/TLX owner's-manual
  Maintenance-Minder pages from a non-gated host if per-model confirmation is
  wanted. (TLX/RDX 2.0T have no timing belt; MDX V6 timing-belt interval was not
  on the read page.)

- **SsangYong severe column — not published.** KGM's Australian schedules give
  only normal-condition intervals and say severe use "may require more frequent
  servicing" without numbers, so no severe figures were recorded. Diesel Tivoli/
  Korando/Rexton variants were excluded (Lebanon diesel ban).

- **Suzuki per-item fluids for the CURRENT range — partial.** Suzuki Australia's
  FAQ gives the current models' service/oil interval (15k NA / 10k turbo) but no
  per-item plug/coolant/brake intervals, and the current Swift/Vitara/Jimny/
  Baleno/Dzire/Ertiga/Ciaz owner's manuals were only on Cloudflare-gated hosts
  (suzuki.com.au owner manuals, ManualsLib — both 403). The per-item figures
  recorded are from the **legacy Grand Vitara** manual and are labelled as such;
  they are **not** asserted for current models. **Round 3 (OLX Swift target) —
  exhausted without a fetchable per-item document:** ManualsLib Swift pages
  (periodic-maintenance table) are Cloudflare-403; Suzuki NZ's service page lists
  the checked items but no intervals; the Suzuki Australia capped-price-service
  PDF (`i-motor.com.au/.../46599_suzuki_capped-price-service-oct2019.pdf`, read
  in full) gives only service **prices** and the 10,000 km / 6 mo (older
  program) interval, and explicitly defers per-item detail to the "Australian
  Supplement of the Owner's Manual" which it does not reproduce; archive.org had
  no copy; other mirrors were spam or scanned (JBIG2). Search snippets of the
  Swift manual recur (coolant Green 45,000 km / 36 mo; plugs ~30,000 km; air
  ~30,000 km) but a snippet is **not** a fetched document, so nothing was
  recorded. The current Swift service/oil interval **is** captured (Suzuki AU
  FAQ: 15k NA DualJet / 10k turbo BoosterJet), and the Suzuki long-life-coolant
  system via the Grand Vitara entry. **Action:** obtain the Swift owner's-manual
  Australian Supplement periodic-maintenance table (or a Maruti equivalent) from
  a non-gated host or by manual upload.

- **Subaru XV / Crosstrek — confirmed already covered, no separate entry.** The
  recorded `_subaruRange` is the make-wide "2022 MY All Vehicles" booklet, whose
  schedule covers the Crosstrek (= the XV in most RHD markets; same FB20 NA
  boxer as the Impreza it shares the table with). The booklet prints one table
  for all non-turbo models, so XV/Crosstrek figures do **not** differ from the
  recorded make-wide values — a separate XV entry would duplicate them, so none
  was added (per the "only add if figures actually differ" rule).

- **Mazda2 — not covered.** Mazda 3, 6, CX-3, CX-30 and CX-9 are now each
  sourced from their own official Mazda USA owner-guide PDF (see Round 2 sources
  below); their figures were **not** copied across models. The Mazda2 is not
  sold in the U.S., so there is no mazdausa.com PDF; its schedule was not
  captured from a clean OEM document. **Action:** source the Mazda2 schedule from
  Mazda Australia / Mazda Europe owner's manuals or `owners-manual.mazda.com/gen/en/demio`.

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
