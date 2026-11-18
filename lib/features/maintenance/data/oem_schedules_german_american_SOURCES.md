# OEM Maintenance Schedule Sources — German & American makes

Companion to `oem_schedules_german_american.dart`. Every interval in that file
cites one of the `source` keys below. This document gives the full provenance
(document, page, publisher, URL) and, honestly, the **gaps** that could not be
sourced and were therefore omitted.

Research date: 2026-11-18. Golden rule observed: **no unverified number was
written** — anything not backed by a document here was left out, not guessed.

Units note: manufacturer docs for these makes publish in **miles**; the Dart
file stores **kilometres**, converted at the repo's standard ×1.6 factor
(10k mi = 16,000 km, 60k mi = 96,000 km, 100k mi = 160,000 km, etc.), matching
`data_backend/verified_specs.json`.

---

## Mercedes-Benz

**Service system:** ASSYST / ASSYST PLUS flexible service — alternating
**Service A** (~10,000 mi / 1 yr) and **Service B** (~20,000 mi / 2 yr). The
on-board Maintenance System sets the actual due point. `conditionBased: true`.

- **`MB MY14 Maintenance Booklet`**
  - Document: *Mercedes-Benz USA MY14 Maintenance Booklet* (Edition B, 2014),
    passenger-car maintenance work by mileage milestone.
  - Publisher: Mercedes-Benz USA.
  - URL: https://www.mbusa.com/vcm/MB/DigitalAssets/pdfmb/maintenancebooklets/MY14_Maintenance_Booklet.pdf
  - Backs (read directly from the booklet, Grade A unless noted):
    - Engine oil & filter — **10,000 mi / 1 yr** ("Change the engine oil and oil
      filter every 10,000 miles or 1 year").
    - Spark plugs — **first 60,000 mi / 6 yr, then every 60,000 mi** (listed at
      the 60k and 120k mile services; "except engine 642" diesel).
    - Air filter — **40,000 mi / 4 yr** normal; **engine 275 (V12)** 60,000 mi /
      6 yr; **engine 133 (AMG 2.0L)** 10,000 mi / 1 yr.
    - Brake fluid — appears at 20k/40k/60k/80k/100k/120k/140k mi services →
      **every 20,000 mi / 2 yr** (Grade A).
    - Cabin / combination filter — listed at nearly every service (≈ every
      10,000 mi / 1 yr); exact cadence is model-column dependent (**Grade B**).
    - Coolant (main circuit) — listed at 30k/60k/90k/120k/150k mi → **≈ every
      30,000 mi / 3 yr** for the relevant engine columns; engines 275/279 check
      concentration yearly instead (**Grade B**, model-column dependent).
    - Transmission (automatic oil & filter) — **model-dependent**, commonly
      ~40,000 mi, some columns 30k–120k mi; **not** a lifetime fill in this
      booklet (**Grade B**).
  - Timing: modern MB gasoline engines use a **timing chain** (inspect only; no
    replacement interval published).

**Mercedes gaps:** no current (MY2024/25) US booklet was retrieved; the MY14
booklet is the latest clean PDF reachable. The A/B baseline is unchanged on
current MB-USA cars but exact per-engine spark/coolant/transmission figures for
newer engines (M254, M256) are **not** sourced here.

---

## BMW

**Service system:** Condition Based Service (CBS) — no fixed odometer table; CBS
computes each item from sensors and driving style. `conditionBased: true`. All
BMW figures are **Grade B**: BMW's own CBS interval PDFs (bmwtechinfo) are gated
and returned 404/timeout, and bmwusa.com blocks automated download, so the
baselines below are corroborated across BMW's described CBS tables and multiple
BMW dealer guides rather than read from a single opened BMW document.

- **`BMW CBS / MY25 Maintenance booklet`**
  - Primary (official, not directly openable here):
    - *BMW MY25 Maintenance booklet* — https://www.bmwusa.com/content/dam/bmw/marketUS/common/warranty-books/2025/BMW_MY25_Maintenance_with_BEVs.pdf
    - *BMW CBS intervals* technical bulletins (gated) — e.g.
      `bmwtechinfo.bmwgroup.com/sib_attachments/B000419 Attachment 2 CBS intervals 10_2021.pdf`
      and `…/B000217 Attachment 2 CBS intervals Rev5 7_20.pdf`.
  - Corroborating dealer/third-party guides: BMW of Grand Blanc
    (`bmwgrandblanc.com/blogs/4100`), BMW of Milwaukee North research-hub 3-Series
    / X3 schedules, RepairPal (`repairpal.com/bmw-maintenance-inspection`),
    JD Power BMW maintenance guide.
  - Backs:
    - Engine oil & filter — oil-service steps ≈ **10,000 mi**; CBS counter sets
      the due point (up to ~1–2 yr). No hard fixed interval.
    - Brake fluid — **every 2 years** (time-based; some X-series bulletins cite a
      36-month first service).
    - Cabin / micro filter — **every 2 years** (or with the brake-fluid service).
    - Spark plugs — ≈ **every 6th oil service ≈ 60,000 mi** on current turbo
      engines; older/NA engines vary (30k–100k mi), model-specific.

**BMW gaps (omitted, not guessed):** engine **air filter** and **coolant** are
handled by CBS "Vehicle Check" with no single published mileage I could source —
**omitted**. **Transmission fluid** — BMW markets most ZF 8HP as "lifetime"; no
cited interval — **omitted**. No BMW primary PDF was opened directly.

---

## Volkswagen

**Service system:** US books publish a **fixed-interval** table (the flexible
LongLife option aside). First minor service 10,000 mi / 1 yr, then 20,000 mi /
2 yr. All values **Grade A — read directly from the VW document.**

- **`VW MY2019 Maintenance Schedule`**
  - Document: *2019 VW Maintenance Schedule — All Models except e-Golf / MY2019
    Maintenance Intervals – USA* (Volkswagen Group of America), filed with NHTSA.
  - Publisher: Volkswagen Group of America.
  - URL: https://static.nhtsa.gov/odi/tsbs/2019/MC-10163818-0001.pdf
  - Backs (exact wording):
    - Engine oil & filter — "First minor maintenance service at **10,000 miles
      or 1 year**… thereafter **20,000 miles or every 2 years**."
    - Brake fluid — "Change — **Every 2 years regardless of mileage**."
    - Air filter element & snow screen — "Replace — **Every 60,000 miles or 6
      years**."
    - Dust & pollen (cabin) filter — "Replace — **Every 40,000 miles or 2
      years**."
    - Spark plugs — "**Every 40,000 miles or 4 years** (Except Atlas, Golf
      SportWagen 1.4L, …)"; "**Every 80,000 miles or 6 years** (Only Atlas, Golf
      SportWagen 1.4L, Golf …)."
    - Transmission — "**6-Speed DSG**: Change **Every 40,000 miles**";
      "**7-Speed DSG**: **Every 80,000 miles**"; "**automatic (non-DSG)**:
      **Every 80,000 miles**" (US; "Filled for life" in Canada).
    - AWD clutch (Haldex) — "Change fluid — **Every 3 years**."
  - Timing: EA888 2.0T / EA211 use a **timing chain** (some EA211 1.4T use a
    belt) — no replacement interval published (**Grade B** note).

**VW gaps:** no **coolant replacement** interval is published (US schedule only
"checks coolant level"; VW G12evo/G13 is long-life) — **omitted**. Exact newer
(MY2023+) spark-plug splits per engine not separately sourced.

---

## Audi

**Service system:** US books publish a **fixed-interval** table. First minor
service 10,000 mi / 1 yr, then 20,000 mi / 2 yr. Values **Grade A — read
directly.** The MY2018–19 schedule has the cleanest model→interval mapping and
is the primary; the MY2021 schedule corroborates.

- **`Audi MY2018-19 Maintenance Schedule`**
  - Document: *2018 Audi Maintenance Schedule — All Models / MY2018 Maintenance
    Intervals – USA* (Revised 5/1/2019), Audi of America, filed with NHTSA.
  - Publisher: Audi of America.
  - URL: https://static.nhtsa.gov/odi/tsbs/2019/MC-10159800-0001.pdf
  - Corroborating: *2021 Audi Maintenance Schedule — All Models* —
    https://static.nhtsa.gov/odi/tsbs/2020/MC-10180343-0001.pdf
  - Backs (exact wording):
    - Engine oil & filter — first **10,000 mi / 1 yr**, then **20,000 mi / 2 yr**.
    - Brake fluid — "**Every 2 years**" (all vehicles).
    - Air filter — "**Every 60,000 miles**" (all except RS7 / A8 LWB, which are
      "**Every 40,000 miles**").
    - Dust & pollen (cabin) filter — "**Every 20,000 miles or 2 years**."
    - Spark plugs (clean model mapping):
      - **40,000 mi / 6 yr** — A3, S3, A4, S4, A4 allroad, A5, S5, A6 2.0T, Q5,
        SQ5, Q7 2.0T, TT 2.0T, TTS (2.0T/4.0T list).
      - **60,000 mi / 6 yr** — A6 3.0T, A7 3.0T, A8 L 3.0T, Q3, Q7 3.0T, R8.
      - **30,000 mi / 3 yr** — RS 3, RS 5, RS 7 performance, S8 plus, TT RS.
    - S tronic (DSG) transmission — "**Every 40,000 miles**" for A4/S4/A5/S5/Q5/
      SQ5/Q7 2.0T etc.; "**Every 80,000 miles**" for some 2.0T B-cycle variants.
    - Front differential — "**Every 120,000 miles or 10 years**" (R8 only).

**Audi gaps:** no **coolant replacement** interval (US schedule only "checks
freeze protection / coolant level"; Audi G12/G13 long-life) — **omitted**.
Timing chain — inspect only, no interval published.

---

## Chevrolet / GMC (General Motors)

**Service system:** GM Oil Life System (algorithmic oil interval; minimum once
per year). `conditionBased: true`. Values **Grade A**, taken from the model-year
US Owner Manuals and **reused verbatim from the repo's own verified dataset**
`data_backend/verified_specs.json` (ingested from these GM manuals). Some GM
`contentdelivery.ext.gm.com` URLs are stored truncated (`/.../`) in that dataset;
the GM owner center is the stable portal: https://www.gmc.com/owner-center/manuals-how-to-guides and https://www.chevrolet.com/support/vehicle/manuals-guides

| `source` key | Document | Page(s) | URL |
|---|---|---|---|
| `Chevrolet Equinox 2023 Owner Manual` | 2023 Chevrolet Equinox Owner Manual (US), General Motors | Capacities p.326; Maint p.319 | https://contentdelivery.ext.gm.com/.../23_CHEV_Equinox_OM_en_US_84895933B.pdf |
| `Chevrolet Traverse 2023 Owner Manual` | 2023 Chevrolet Traverse Owner Manual (US), GM | Capacities p.334; Maint p.327 | https://contentdelivery.ext.gm.com/.../23_CHEV_Traverse_OM_en_US_84999704B.pdf |
| `Chevrolet Tahoe/Suburban 2023 Owner Manual` | 2023 Chevrolet Tahoe/Suburban Owner Manual (US), GM | Capacities & Specs p.408; Maint p.401 | https://contentdelivery.ext.gm.com/.../23_CHEV_Tahoe_Suburban_OM_en_US_84979315B.pdf |
| `GMC Terrain 2022 Owner Manual` | 2022 GMC Terrain Owner Manual (US), GM | Capacities p.351 | https://www.gmc.com/ownercenter/content/dam/gmownercenter/gmna/dynamic/manuals/2022/gmc/terrain/2022-gmc-terrain-owners-manual.pdf |
| `GMC Acadia 2022 Owner Manual` | 2022 GMC Acadia Owner Manual (US), GM | Capacities p.357-359 | https://www.gmc.com/ownercenter/content/dam/gmownercenter/gmna/dynamic/manuals/2022/gmc/acadia/2022-gmc-acadia-owners-manual.pdf |
| `GMC Yukon 2023 Owner Manual` | 2023 GMC Yukon Owner Manual (US), GM | Capacities & Specs p.407; Maint p.398 | https://contentdelivery.ext.gm.com/.../23_GMC_Yukon_OM_en_US_16417394C.pdf |

Backs: oil & filter (GM Oil Life, min 12 mo); spark plugs (Equinox/Terrain 60k
mi = 96,000 km; Traverse/Acadia/Tahoe/Yukon 97,500 mi = 156,000 km); Tahoe/Yukon
coolant 150,000 mi / 6 yr (240,000 km / 72 mo) and cabin filter 36,000 km / 24 mo.

**GM gaps:** brake fluid — GM lists "no scheduled interval / inspect" for most of
these; no cited number — **omitted**. Air filter and transmission intervals were
not part of the ingested rows for the SUV/crossover models — **omitted**.

---

## Ford

**Service system:** Intelligent Oil-Life Monitor (IOLM; up to 1 yr / 10,000 mi).
`conditionBased: true`. Values **Grade A**, from the model-year US Owner Manuals
(Ford Motor Company), **reused from the repo's verified dataset**.

| `source` key | Document | Page(s) | URL |
|---|---|---|---|
| `Ford Escape 2022 Owner Manual` | 2022 Ford Escape Owner Manual (US), Ford | Capacities p.395-402; Maint p.485-492 | https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2022-Ford-Escape-Owners-Manual-version-1_om_EN-USA_09.2-2021.pdf |
| `Ford Explorer 2022 Owner Manual` | 2022 Ford Explorer Owner Manual (US), Ford | Capacities p.382-413; Maint p.479-482 | https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2022-Ford-Explorer-Owners-Manual-version-1_om_EN-US_09_2021.pdf |
| `Ford F-150 2022 Owner Manual` | 2022 Ford F-150 Owner Manual (US), Ford | Capacities p.562-587; Maint p.646-652 | https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2022-Ford-F-150-Owners-Manual-version-1_om_EN-US_10_2021.pdf |
| `Ford Mustang 2023 Owner Manual` | 2023 Ford Mustang Owner Manual (US), Ford | Capacities p.349-368; Maint p.452-461 | https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2023_Ford_Mustang_Owners_Manual_version_1_om_EN-US.pdf |

Backs: oil & filter (IOLM, 16,000 km / 12 mo); spark plugs (Escape/Explorer/
Mustang 100,000 mi = 160,000 km; F-150 60,000 mi = 96,600 km); Explorer/F-150
air filter 30,000 mi, cabin filter 20,000 mi, transmission 150,000 mi, brake
fluid every 3 yr, coolant first change 200,000 mi (322,000 km).

**Ford data-quality note:** the repo's verified_specs row for the **Mustang** oil
item carried a copy-paste error ("GM Oil Life System"). Ford uses **IOLM**; the
note was corrected in the Dart file while the sourced numbers (oil min. 12 mo;
plugs 160,000 km) were kept unchanged. The Mustang row did not carry a distance
oil interval, so none was invented.

**Ford gaps:** Escape/Mustang rows did not include air filter, cabin filter,
transmission, brake fluid, or coolant — **omitted** (not copied from the larger
Explorer/F-150 set, to avoid cross-model assumptions). Ford 1.0/1.5L EcoBoost
uses a **wet (belt-in-oil) timing belt** with a replacement interval in some
markets; the US manual treats it as inspect-based and no interval was sourced —
**omitted / flagged**.

---

## Summary of what is sourced vs. gaps

**Fully sourced, Grade A (read from an opened official document):**
- Volkswagen MY2019 — oil, brake fluid, air filter, cabin filter, spark plugs
  (both tiers), transmission (DSG 6/7-speed + non-DSG).
- Audi MY2018–19 — oil, brake fluid, air filter, cabin filter, spark plugs
  (three tiers), S tronic transmission, front diff.
- Mercedes-Benz MY14 — oil, spark plugs, air filter, brake fluid (Grade A);
  cabin filter, coolant, transmission (Grade B — model-column dependent).
- Chevrolet / GMC / Ford — oil (Oil Life / IOLM), spark plugs, and (where in the
  ingested rows) coolant, cabin/air filter, transmission, brake fluid — Grade A,
  via the repo's verified_specs dataset ingested from the GM/Ford US manuals.

**Grade B (corroborated, not read from a single opened primary):**
- All BMW figures (CBS PDFs gated / bmwusa blocks download).

**Honest gaps (omitted, never invented):**
- BMW engine air filter, coolant, transmission fluid.
- VW / Audi coolant replacement interval (long-life; US schedules only check it).
- GM brake fluid, and air/transmission for the GM crossovers not in the dataset.
- Ford Escape/Mustang non-oil/plug items; Ford wet-belt timing interval.
- Any current (MY2024–26) Mercedes/BMW per-engine figures beyond the baselines.

---

## Gap-fill pass — 2026-11-18

A second pass re-sourced several of the gaps above by opening additional
official documents directly (PDF text extracted and read, not inferred). Two
app-side directives shaped what was captured: (1) **always keep a concrete
displayable number** even for condition-based systems, flagged `conditionBased`;
(2) **Lebanon = severe-use market**, so published SEVERE / "special operating
conditions" columns were captured alongside normal, and the app will prefer the
severe value.

### BMW — spark plugs, S68T V8 (NEW, Grade A)
- **`BMW SIB 62 02 25 (NHTSA)`**
  - Document: *BMW of North America Service Information Bulletin SIB 62 02 25,
    "SERVICE ACTION: CBS CORRECTION FOR SPARK PLUG REPLACEMENT INTERVAL"*,
    2025-02-26, filed with NHTSA.
  - URL: https://static.nhtsa.gov/odi/tsbs/2025/MC-11014663-0001.pdf
  - Applies to S68T 4.4L TT V8 (F95 X5 M, F96 X6 M, G05 X5, G06 X6, G07 X7,
    G09 XM, G70 7 Series).
  - Read verbatim: *"the initial mileage was set to 15,000 miles (~25,000 km)
    instead of the correct mileage value of 40,000 miles (~60,000 km)."* So the
    correct spark-plug interval = **40,000 mi** (stored 64,000 km at ×1.6; BMW's
    own round figure is ~60,000 km). CBS counter still sets the actual due point.
  - This is a SEPARATE, shorter interval than the general ~60,000 mi turbo
    baseline already in the file.
- **BMW still-open gaps:** the BMW USA MY25/MY26 Maintenance booklet
  (`bmwusa.com/.../BMW_MY25_Maintenance_with_BEVs.pdf`) could **not** be opened
  by any available route — bmwusa.com resets curl connections (bot protection),
  times out plain fetch (>60 s), serves the PDF as a download (no in-browser
  render), and the Google-viewer proxy + manualslib mirror are bot-gated
  (Cloudflare). `bmwtechinfo.bmwgroup.com` attachments return 404 (gated).
  So BMW **engine air filter, coolant, and transmission fluid remain gaps** —
  BMW publishes these as lifetime / CBS "Vehicle Check" with no fixed interval,
  so there is no official number to record. The existing BMW oil / brake-fluid /
  cabin-filter / plug baselines (Grade B) remain the displayable numbers.

### Ford — Escape non-oil/plug items (NEW, Grade A) + severe
- **`Ford Escape 2022 Owner Manual`** (same document already cited for oil/plugs;
  URL in the Ford table above). PDF opened and the "Normal Scheduled
  Maintenance", "Brake Fluid Maintenance", "Other Maintenance Items", and
  "Special Operating Conditions Scheduled Maintenance" tables read directly:
  - Cabin air filter — **every 20,000 mi (32,000 km)**.
  - Engine air filter — **every 30,000 mi (48,000 km)**.
  - Automatic transmission fluid — **every 150,000 mi (240,000 km)** normal;
    **every 30,000 mi (48,000 km)** under severe (extensive idling / heavy
    commercial / dusty-sandy columns).
  - Brake fluid — **every 3 years**.
  - Engine coolant — **initial at 10 yr / 200,000 mi (322,000 km), then every
    5 yr / 100,000 mi (160,000 km)**.
  - Spark plugs — **100,000 mi** normal (already recorded); **60,000 mi
    (96,000 km)** under severe (new severe row).
  - **Wet-belt timing:** the 1.5L EcoBoost uses a belt-in-oil timing belt, but
    the US manual lists **no** "timing belt" replacement interval anywhere
    (grep confirmed) — inspect-based only, left without a number (Grade B note).
- **Ford Mustang gap NOT closed:** the 2023 Mustang Owner Manual
  (`fordservicecontent.com/.../2023_Ford_Mustang_Owners_Manual_version_1_om_EN-US.pdf`)
  is blocked by Ford's Akamai edge for curl (403) and exceeds the 10 MB plain-
  fetch cap; every mirror found was either the same blocked host or Cloudflare-
  gated. Mustang non-oil/plug items (air/cabin filter, transmission, brake
  fluid, coolant) therefore **remain gaps** — not copied from Escape/Explorer,
  because the Mustang is RWD with a different transmission.

### GM — full-size SUVs, Middle-East edition (NEW, Grade A) + severe
- **`GM Tahoe/Suburban/Yukon 2024 ME Owner Manual`**
  - Document: *Chevrolet/GMC Tahoe/Suburban/Yukon/Yukon XL/Denali Owner Manual
    (GMNA-Localizing-MidEast-17746374) – 2024 – CRC – 10/9/23*, General Motors.
    The **Middle-East edition** — the market-correct book for Lebanon; it prints
    intervals natively in **kilometres** (so no mile→km conversion was applied).
  - URL (dealer-hosted copy of the GM-authored file, GM filename
    `24_mul_tahoe_suburban_yukon_om_en_us_i_meo_85657857_2023oct13_hi.pdf`):
    https://chevrolet.alghandi.com/static/pdfs/24_mul_tahoe_suburban_yukon_om_en_us_i_meo_85657857_2023oct13_hi.pdf
    (GM's own `contentdelivery.ext.gm.com` host did not expose a current direct
    URL; the content is the identical GM-generated PDF.)
  - "Service and Maintenance" section (pp. 355–359) read directly:
    - Brake fluid — **every 5 years** (closes the GM brake-fluid gap).
    - Passenger-compartment (cabin) air filter — **every 10,000 km or
      12 months** (ME value; the US 2023 book's 36,000 km / 24 mo stays as its
      own entry).
    - Engine air filter — Engine Air Filter **Life System** (condition-based):
      inspect every **10,000 km or 6 months**; replace on message. No fixed km.
    - Spark plugs — **every 150,000 km**.
    - Engine coolant — **every 240,000 km or 6 years** (confirms existing value).
    - Automatic transmission fluid & filter — **SEVERE only: every 70,000 km**;
      normal service publishes no transmission interval (fill-for-life). Lebanon
      = severe, so 70,000 km applies (closes the GM transmission gap).
    - Transfer-case fluid (4WD) — **160,000 km normal / 80,000 km severe**.
    - Oil — Oil Life System, change within 1,000 km of CHANGE ENGINE OIL SOON,
      min once/yr; 10,000 km required-services cadence. Baseline: ~10,000 km/12 mo.
  - Severe-service triggers per the manual: heavy city traffic in hot weather,
    hilly terrain, high sand/dust, short trips ≤6 km, commercial use — i.e.
    typical Lebanon conditions.
  - **Silverado note:** the Silverado 1500 shares the L84/L87 GM full-size
    schedule but a Silverado-specific manual was **not** opened this pass, so no
    Silverado entry was added (would need its own document to cite).

### VW / Audi coolant — re-checked, still a gap
Re-searched for an official VW/Audi coolant **replacement** interval (US and EU).
Only secondary/forum/retailer figures exist (2 yr/30k mi, 4–5 yr, etc.), which
disagree and are not manufacturer documents. VW/Audi long-life coolant
(G12evo/G13) is "check only" in the US schedules already cited. **No official
fixed coolant replacement interval found — remains omitted, not guessed.**
