# OEM maintenance schedules — Chinese makes: sources & coverage

Companion to `oem_schedules_chinese.dart`. Every interval in that file is
traceable to one of the sources below. This mirrors the `verified_specs`
discipline (`data_backend/README.md`) and the sibling
`oem_schedules_japanese_SOURCES.md`: **incomplete coverage is fine; an
unverified displayed value is not.** Nothing was inferred, guessed, or copied
across makes/models. Chinese brands are very popular in Lebanon and many are
electric, so EV item sets (brake fluid, powertrain/battery coolant, cabin/HEPA
filter, reduction-gear "reducer" oil, HV-battery check) were captured where the
vehicle is a BEV, and the `fuel` field records the powertrain.

Grades: **A** = read directly from a manufacturer / official-importer
maintenance document. **B** = official but market-specific dealer/importer
schedule or capped-price/service-cost sheet, or a value taken from an explicit
prose note. **C** = figure only positionally implied by the source (needs
confirmation before display).

---

## Sources used (all fetched and read, not search snippets)

### BYD

1. **BYD Cyprus (official importer) — "Service Intervals EV (EN)", PDF, 2025** (Grade B)
   `https://bydauto.com.cy/wp-content/uploads/2025/06/Service-Intervals-EV-EN.pdf`
   One EV table applicable to **Atto 3, Atto 2, Dolphin, Seal RWD, Seal AWD,
   Seal U EV, Sealion**. Base interval 30,000 km / 24 months (columns
   30/60/90/120/150 ×1000 km at 24/48/72/96/120 months). Backs: brake fluid R
   30,000 km/24 mo; cabin HEPA/A-C filter R 30,000 km/24 mo; gearbox (reduction)
   oil R 48,000 km/24 mo; Power Distribution Unit coolant R at 90,000 km/72 mo
   (coolant *level* inspected each interval); HV battery inspected each interval;
   tyre rotation recommended ~every 10,000 km.

2. **BYD South Africa (official) — "ATTO 3 Warranty & Service Booklet", Service Schedule & Log (pp.18–19)** (Grade B)
   `https://www.byd.com/material/byd-site/za/warranty-%26-service-booklets/ATTO%203%20WARRANTY%20%26%20SERVICE%20BOOKLET.pdf`
   Atto 3 BEV, **different market schedule** from source 1: base 2 years /
   40,000 km, first check 20,000 km / 12 months. Backs: brake fluid R every
   2 yr / 40,000 km; drive-motor coolant R every 4 years; gear oil &
   transmission servicing "from 40,000 km onward" (recurring figure not stated →
   Grade C). Kept separate from the Cyprus sheet (not merged).

3. **BYD Brazil (official) — "SONG Plus DM-i (2025/2026)" revision schedule, eff. 01-09-2026** (Grade B)
   `https://www.byd.com/material/__CN/byd-site/br/manuais-p%C3%B3s-vendas/updates-01-09-2026/SONG%20Plus%20DM-i%20%282025_2026%29.pdf`
   DM-i plug-in hybrid. This is a revision-pricing schedule — only the **cadence**
   is published: every 12,000 km ODO or 12 months (to 120,000 km). Per-item
   fluid intervals are **not** itemised, so only the base interval is recorded.

### Chery

4. **Chery Egypt (official) — "Chery New EQ7 Maintenance Schedule", PDF** (Grade A, some rows omitted)
   `https://chery-eg.com/media/maintenance_schedules/Maintanance_EQ7.pdf`
   EQ7 is a **BEV**. Backs (clear prose statements): coolant — incl. drive-motor
   and power-battery cooling — every 2 yr / 40,000 km; reducer gear oil first
   2 yr / 30,000 km then every 3 yr / 40,000 km; power-battery check every
   5,000 km; tyre rotation at each service. The brake-fluid and A/C-filter rows
   in the bilingual (Arabic/English) table could not be mapped to a km figure
   unambiguously and were **omitted**.

### Changan

5. **Changan Philippines (official importer) — "Standard PMS Menu for All Changan Models", PDF** (Grade A/B/C)
   `https://www.changan.ph/media/l3gp2w40/pms-menu-for-changan.pdf`
   Range-wide table for **Alsvin, CS15, CS35 Plus, CS55 Plus, X7, UNI-T, UNI-K**.
   Base interval first 5,000 km / 3 mo, then every 10,000 km / 6 mo
   (months 3/9/15/21… ; km 5/15/25/35… ×1000). Backs (prose "Replace every X"):
   MT/AT/DCT transmission fluid 55,000 km; power transfer unit oil (4WD)
   55,000 km; brake/clutch fluid 75,000 km (Grade B — row-to-figure mapping
   slightly uncertain). Engine oil & filter graded **C** — positionally on the
   PMS cadence; footnote *2 only states "check engine oil level and leak every
   500 km". The per-cell R/I grid was not machine-readable row-by-row, so no
   other per-item figures were taken.

### GWM / Haval

6. **GWM New Zealand (official importer) — "H6 Service NZ 2025" scheduled-maintenance tables** (Grade A)
   `https://assets.gwmanz.com/f/256395/x/9eed77357a/h6_service_nz_2025.pdf`
   Three tables (petrol / H6 HEV / H6 PHEV). Base interval first 10,000 km /
   12 mo then every 15,000 km / 12 mo (km 10/25/40/55/70/85/100/115/130/145
   ×1000). Clear prose figures backed:
   - **Petrol:** engine oil & filter at every service; spark plugs first 70,000 km/
     60 mo then 60,000 km/48 mo; auto transmission + pressure filter first
     55,000 km/48 mo then 60,000 km/48 mo; generator/water-pump belt replace
     100,000 km/84 mo (inspect every 2nd service).
   - **HEV/PHEV (DHT):** spark plugs first 40,000 km/36 mo then 45,000 km/36 mo;
     DHT oil (incl. front diff) first 55,000 km/48 mo then 60,000 km/48 mo; DHT
     transmission filter (AWD) first 55,000 km/48 mo then 60,000 km/48 mo;
     engine coolant first 55,000 km/48 mo then 60,000 km/48 mo; EV/electrical
     driving-system coolant first 70,000 km/60 mo then 75,000 km/60 mo; rear diff
     gear oil (AWD, **severe**) every 55,000 km/48 mo.
   Air-filter, cabin-filter and brake-fluid cells (R/I grid) could not be read to
   an exact km and were **omitted**. Footnote "* Shorter in severe environment".

7. **GWM Australia (official importer) — "GWM Haval H6GT" Capped Price Service & Service Schedule, PDF** (Grade B)
   `https://assets.gwmanz.com/f/256395/x/11515d041a/gwm-haval-h6gt-cps-au.pdf`
   Cadence: 1st 12 mo/10,000 km; 2nd 24 mo/25,000 km; 3rd 36 mo/40,000 km; 4th
   48 mo/55,000 km; 5th 60 mo/70,000 km. Backs (prose): disc brakes front & rear
   replace every 100,000 km; ball joint & dust cover / radiator every 48 mo /
   55,000 km; air cleaner element every 60,000 km under Severe Duty.

8. **GWM Malaysia (official) — "HAVAL H HEV Maintenance Schedule", PDF** (Grade B)
   `https://www.gwm.com.my/content/dam/gwm/pages/my/en/exclusive-service/pdf/maintenance-haval.pdf`
   Service/parts price matrix (12/24/36/48/60 mo = 10,000/25,000/40,000/55,000/
   70,000 km). One unambiguous long-interval figure: transmission (DHT) fluid
   first replacement at 145,000 km / 120 months. Multipoint inspection + tyre
   rotation every interval.

### MG

9. **MG Singapore (official importer) — "Aftersales Service Schedule" article** (Grade A, interval only)
   `https://mg.com.sg/Articles/AftersalesServiceSchedule`
   Base service interval per model: **MG HS (petrol), MG4 EV, MG5 EV, MG ZS EV,
   MG S5 EV = 10,000 km or 6 months** (MG M9 EV 15,000 km/12 mo; Cyberster
   25,000 km/12 mo). No item-level intervals on this page.

### Geely

10. **Geely Saudi Arabia (official importer, MENA) — "Periodic Maintenance / Service Cost" page** (Grade B)
    `https://geelyksa.com/service-cost/`
    Per-model service interval: Coolray / New Coolray / Azkarra / Tugella /
    Emgrand A1 / GX3 Pro = 10,000 km / 12 months (to 150,000 km); **New Emgrand**
    = first 5,000 km/3 mo, 2nd 12,500 km/9 mo, then every 7,500 km/6 mo. One
    item figure: external fuel filter replaced every 30,000 km (in-tank filter
    maintenance-free). No other item intervals published on the page.

### Chery / Omoda (ICE petrol — NEW)

11. **Chery Malaysia (official) — per-model "Service Schedule & Pricing Guide" PDFs** (Grade A)
    - Omoda 5 / Omoda C5 ("THE NEW CHERY O5"): `https://www.chery.my/wp-content/uploads/2025/09/Chery-Service-Maintenance-Schedule_O5_2025_compressed-1.pdf`
    - Tiggo 7 Pro: `https://www.chery.my/wp-content/uploads/2025/08/Chery-Service-Pricing-Guide_TIGGO-7-PRO_2025.pdf`
    - Tiggo 8 Pro: `https://www.chery.my/wp-content/uploads/2025/08/Chery-Service-Maintenance-Schedule_TIGGO-8-PRO_2025.pdf`
    - Tiggo Cross (1.5T + 6DCT): `https://www.chery.my/wp-content/uploads/2025/07/tiggocross-service-maintenance-schedules.pdf`
    Manufacturer compulsory-maintenance tables. Columns 1/10/20…150 ×1000 km at
    1/6/12…84 months (base 10,000 km / 6 months; 1,000 km break-in is FOC). The
    guides are scanned images with an embedded text layer; each sparse row was
    cross-checked against the printed **TOTAL SERVICE & MAINTENANCE FEE** column
    so the service→km mapping is exact. Backs — **Omoda C5/O5:** oil+filter
    10k/6mo, air filter 20k/12mo, spark plugs 30k, brake fluid / DCT oil / coolant
    all 40k/24mo. **Tiggo 7 Pro & Tiggo 8 Pro:** oil+filter 10k/6mo, air filter
    20k/12mo, spark plugs 30k, brake fluid 40k/24mo, DCT oil + coolant 50k/30mo
    (Tiggo 8 Pro is 1.6T / 0W20). **Tiggo Cross:** oil+filter 10k/6mo, air filter
    20k/12mo, spark plugs 30k, brake fluid 40k/24mo, 6DCT oil 60k/36mo (no coolant
    row on this guide — omitted). No normal/severe split published.

### JAC (ICE petrol — NEW)

12. **JAC Qatar (official importer) — "JAC JS4 1.5T CVT" periodic maintenance table** (Grade A)
    `https://web.archive.org/web/20240831155910/https://www.jacqatar.com/wp-content/uploads/2024/01/JS4-1.pdf`
    (Live jacqatar.com link now Cloudflare-blocked (403); read via Internet
    Archive snapshot.) Clean R/I grid, columns 10K–120K km paired 10,000 km ⇄
    6 months. Backs — oil+filter 10k/6mo; air + A/C filter 20k/12mo; fuel filter
    40k/24mo; brake fluid 40k/24mo; CVT oil + filter 60k/36mo; spark plugs
    60k/36mo; engine coolant first R at 80k/48mo (first-change baseline). JS6 NOT
    in this doc → gap (not copied).

### Deepal (Changan EV brand — NEW; BEV-vs-EREV determination)

13. **Changan UK / Deepal (official importer, changaneurope.com) — "Service Schedules"** (Grade B)
    `https://website-editor.changaneurope.com/uk/owners/service-schedules`
    Year/mileage per-item schedule. UK market lists **S07 and S05 as BEV** and the
    **S05 as PHEV** (the PHEV's engine item set — engine oil, spark plugs, engine
    air filter — confirms it has an engine). Base service every 12 months /
    12,000 mi; per-item intervals year-based (2/4/6th yr = 24 mo; 3/6th yr =
    36 mo). Distances published in **miles only**, so `intervalKm` left null (mile
    figure noted, not converted). Recorded: **S07 BEV** (brake fluid 24mo, cabin
    filter 24mo, coolant 36mo, electric-drive/reducer oil 36mo, HV-battery check
    36mo) and **S05 PHEV** (engine oil 12mo, spark plugs 24mo, engine air filter
    24mo, e-drive transmission oil 36mo, brake fluid 24mo, cabin filter 24mo,
    coolant 36mo). NOTE: a separate **S07 REEV / range-extender** variant exists
    in other markets (its REEV owner's manual is online) but no reachable per-item
    schedule was captured → NOT recorded (would need its own `fuel` + engine-oil
    set). Nothing copied across variants.

### Geely (ICE petrol — item-level, NEW)

14. **Geely Chile (official importer) — "Geely Warranty book all models", "Mantención Programada" schedule** (Grade A)
    `https://www.geely.cl/content/uploads/2026/03/Geely-Warranty-book-all-models.pdf`
    75-page owner warranty & maintenance book. The "Mantención Programada" grid +
    special-fluids pages for **New Coolray / Coolray Lite / Cityray** (engine
    4G15TD, oil API SP 0W-20, brake DOT4): oil+filter 10k/12mo; air + A/C filter
    20k/24mo; spark plugs (bujía) R at services 4 & 8 → 40k/48mo; coolant "cada
    24 meses o 40.000 km"; brake fluid "cada 24 meses o 40.000 km"; fuel filter
    "cada 1 año o 30.000 km"; drive belt "cada 36 meses o 60.000 km"; **CVT**
    fluid single change at 40k then maintenance-free; **manual** transmission
    first 10k then every 30k/24mo. Confirms base 10,000 km / 12 months (EX5
    20,000 km). Upgrades the interval-only Geely entry for Coolray; Emgrand not
    tabulated here → Emgrand item-level remains a gap.

---

## Coverage summary (what was sourced)

| Make | Models sourced | Level | Normal | Severe |
|------|----------------|-------|:------:|:------:|
| BYD | Atto 3/2, Dolphin, Seal (RWD/AWD), Seal U EV, Sealion (BEV) | item-level | ✓ | — |
| BYD | Atto 3 (ZA booklet, BEV) | item-level | ✓ | — |
| BYD | Song Plus DM-i (PHEV) | interval only | ✓ | — |
| Chery | EQ7 (BEV) | item-level (partial) | ✓ | — |
| Changan | Alsvin, CS15, CS35 Plus, CS55 Plus, X7, UNI-T, UNI-K | item-level (partial) | ✓ | — |
| GWM/Haval | H6 petrol; H6 HEV/PHEV (DHT); H6 GT; H HEV (MY) | item-level | ✓ | ✓ (rear diff, air filter) |
| Chery (Omoda) | Omoda C5 / Tiggo 7 Pro / Tiggo 8 Pro / Tiggo Cross (ICE petrol) | item-level | ✓ | — |
| JAC | JS4 1.5T CVT (ICE petrol) | item-level | ✓ | — |
| Deepal | S07 BEV; S05 PHEV (time-based) | item-level | ✓ | — |
| MG | HS, ZS EV, MG5 EV, MG4 EV, S5 EV | interval only | ✓ | — |
| Geely | Coolray (New/Lite/Cityray) — full item set | item-level | ✓ | — |
| Geely | Emgrand, Azkarra, Tugella, GX3 Pro, A1 | interval + fuel filter | ✓ | — |
| **Chery Tiggo 2 / Tiggo 4 Pro (ICE)** | **none** | — | — | — |
| **Jetour X70 / Dashing** | **none** | — | — | — |
| **JAC JS6** | **none** | — | — | — |
| **Avatr 11/12** | **none** | — | — | — |
| **Voyah (Free/Dreamer EREV, Courage BEV)** | **none** | — | — | — |
| **Seres / Aito M5, M7 (EREV + BEV)** | **none** | — | — | — |

---

## Gaps (honest, un-padded)

- **MG item-level — gap.** MG's base interval (10,000 km / 6 months) is solid
  from MG Singapore, but the per-item figures (brake fluid, coolant, spark
  plugs, reduction-gear oil) live in a separate "Service Schedule" / "Periodical
  Maintenance Table" booklet. MG's own hosts returned **404** (`www.mgcars.com`
  AfterSalesService PDFs) and **500** (`ex-prod.mgcars.com`); `manualslib.com`
  copies are Cloudflare-blocked (403); the full MG5 owner's manual (fetched,
  ~52 MB) only *defers* to that booklet without printing the numbers. Search
  snippets suggest MG5 EV brake fluid 2 yr, coolant 4 yr/96,000 km, e-drive
  transmission fluid 96,000 km — **not** confirmed against a fetched document, so
  **not** recorded. **Action:** obtain an MG Periodical Maintenance Table PDF
  from a working host (or MG Middle East importer), or manual upload.

- **Chery Tiggo 7 Pro / Tiggo 8 Pro / Omoda C5 / Tiggo Cross (ICE) — RESOLVED
  (item-level).** Captured from Chery Malaysia official Service Schedule &
  Pricing Guides (source 11). See that entry for the per-item figures.
  **Remaining gap — Chery Tiggo 2 / Tiggo 4 Pro (ICE):** Malaysia does not
  publish these (all `chery.my` guide-URL probes 301-redirected), and the Chery
  Egypt `chery-eg.com/media/maintenance_schedules/...` path (which hosts the real
  EQ7 PDF) returned 404 for every Tiggo-name guess. **Action:** scrape the exact
  media links from the Chery Egypt / South Africa after-sales pages (JS-rendered),
  or get the owner's service booklet. No figure was copied from Tiggo 7/8 Pro or
  across models for the 2 / 4 Pro.

- **Changan per-item ICE detail — partial.** The PMS cadence and the
  transmission/transfer/brake-fluid figures are solid; the per-cell R/I grid
  (engine oil, coolant, spark plugs, air/fuel filter exact km) was not
  machine-readable row-by-row from the PDF, so those were graded C or omitted.
  CS75 Plus, Eado and UNI-K/UNI-T were only partly covered by the one PH table.
  **Action:** fetch per-model Changan owner's-manual schedules (or the Changan
  MENA/KSA service-plan sheets) for the grid items.

- **Geely Coolray item-level — RESOLVED.** Full item set (oil, air/cabin filter,
  spark plugs, coolant, brake fluid, fuel filter, belt, CVT + manual transmission
  fluid) captured from the Geely Chile all-models warranty & maintenance book
  (source 14). **Remaining gap — Geely Emgrand item-level:** not tabulated in
  that book; base interval only (Geely KSA). **Action:** fetch an Emgrand owner's
  maintenance booklet for its grid.

- **Jetour (X70 / Dashing) — complete gap.** Only distributor **marketing** PMS
  summaries (Philippines, UAE, KSA) were found — no fetchable official schedule
  table. `jetourksa.com/aftersales/services-warranty` now 404s. **Action:**
  obtain the Jetour owner's service booklet or a working importer PMS PDF.

- **JAC JS4 — RESOLVED (item-level)** from the JAC Qatar JS4 1.5T CVT table via
  the Internet Archive (source 12). **Remaining gap — JAC JS6:** no published
  JS6 schedule was reachable (JS6-1.pdf on jacqatar.com is Cloudflare-blocked and
  not in the Wayback Machine). No JS6 figure was copied from JS4. **Action:**
  source a JAC JS6 owner's-manual schedule or importer sheet.

- **Avatr 11/12 — complete gap.** Avatr publishes the schedule only in-car / in
  the Avatr app; no public owner's-manual or importer schedule was reachable.
  Avatr is BEV/EREV; the BYD EV sheet was **not** copied across (different
  brand). **Action:** capture the Avatr in-app/owner's-manual schedule, or an
  Avatr Europe/MENA importer sheet.

- **Deepal S07 REEV (range-extender) — gap.** The Changan UK schedule (source 13)
  covers the S07/S05 **BEV** and the S05 **PHEV**, all recorded. The separate
  **S07 REEV** (range-extender, has an engine + oil) has an English owner's manual
  online (flippingbook) but no reachable per-item *schedule* table, so it was NOT
  recorded — it needs its own `fuel: 'Range-extender'` + engine-oil set. No REEV
  figure was inferred from the BEV schedule.

- **Voyah — gap (powertrain confirmed, no schedule).** Determined from sources:
  **Voyah Free** and **Voyah Dreamer** are EREV (1.5T range-extender generator +
  battery; Free also has a PHEV "318" variant), **Voyah Courage** is BEV. No
  official/importer maintenance schedule (BEV *or* EREV) was reachable, so no
  intervals were recorded. **Action:** obtain a Voyah owner's-manual maintenance
  table per variant.

- **Seres / Aito (M5, M7) — gap (powertrain confirmed, no schedule).** Both M5
  and M7 ship in **EREV** (1.5T range-extender, has engine oil) **and BEV**
  variants. No official maintenance schedule was reachable for either, so nothing
  was recorded (and EREV vs BEV must not share a schedule). **Action:** obtain a
  Seres/Aito owner's-manual maintenance table per variant.

- **BYD DM-i / PHEV item-level — partial.** Song Plus DM-i gives only the
  12,000 km / 12-month cadence (BYD Brazil pricing schedule). The per-item ICE
  items for the DM-i engine (oil, spark plugs, engine coolant, fuel filter) were
  not itemised there and are not recorded. **Action:** fetch a BYD DM-i
  owner's-manual "Maintenance Cycle and Items" table (Seal U DM-i / Song Plus
  DM-i / Qin / Han DM).

- **General:** several makes host their schedules as JS-rendered SPA pages
  (`mgcars.com`) or behind Cloudflare (`manualslib.com`), and some importer PDF
  links are signed/hotlink-protected. Only values read from a successfully
  fetched document were recorded; everything else is listed above as a gap.
