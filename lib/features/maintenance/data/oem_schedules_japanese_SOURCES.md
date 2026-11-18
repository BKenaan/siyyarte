# OEM maintenance schedules — Japanese & Korean makes: sources & coverage

Companion to `oem_schedules_japanese.dart`. Every interval in that file is
traceable to one of the sources below. This mirrors the `verified_specs`
discipline (`data_backend/README.md`): **incomplete coverage is fine; an
unverified displayed value is not.** Nothing was inferred, guessed, or copied
across makes. Where no trustworthy source was reachable, the item is listed as a
**gap**, not filled in.

Grades: **A** = read directly from a manufacturer / official-importer
maintenance document. **B** = official but market-specific dealer/importer
schedule, or a value taken from an explicit footnote. **C** = figure only
positionally implied by the source (needs confirmation before display).

---

## Sources used

### Toyota

1. **Toyota New Zealand — "Service Requirements: Petrol Hybrid Vehicles", v. Sept 2023** (Grade A)
   `https://www.toyota.co.nz/globalassets/owners/servicing-your-toyota/toyota-petrol-hybrid-service-requirements.pdf`
   Backs (Toyota petrol-hybrid range, normal conditions): engine oil & filter
   15,000 km/12 mo; brake fluid 30,000 km/24 mo; engine air filter 75,000 km;
   iridium spark plugs 90,000 km; e-CVT fluid 90,000 km; engine/heater +
   inverter coolant first 150,000 km then 75,000 km; rear diff fluid (AWD)
   90,000 km; timing belt 150,000 km. (Severe = "shorten", not quantified.)

2. **Toyota Brunei — "Periodic Maintenance Service (PMS) table", rev. 01-09-2022** (Grade B, except plug note Grade A)
   `https://www.toyota.com.bn/media/nlqnjp0d/pms-table-01092022-rev-1-1.pdf`
   Backs (single tropical-market table): engine oil & filter 5,000 km/3 mo;
   brake fluid / cabin filter / engine air filter / fuel filter / ATF / coolant
   / differential all 40,000 km; spark plugs standard 20,000 km, iridium
   100,000 km (this plug note is Grade A — it matches Toyota's global factory
   figures). Treated as a hot-climate, severe-leaning schedule; **not** the
   global owner's-manual normal/severe split.

### Nissan

3. **Nissan South Africa — X-Trail Periodic Maintenance schedule (PDF)** (Grade A)
   `https://www.nissan.co.za/content/dam/Nissan/za/Maintenance/X-Trail.pdf`
   Full normal **and** severe tables. Backs 2.0/2.5 petrol (MR20/QR25) and 1.6
   diesel (R9M): oil & filter 15,000 km/12 mo (severe 7,500 km/6 mo); air filter
   30,000 km/24 mo; iridium plugs 90,000 km; coolant first 150,000 km then
   75,000 km/48 mo; brake fluid 30,000 km/24 mo (severe 15,000 km/12 mo); CVT
   fluid 90,000 km; cabin filter 30,000 km/24 mo; diff oil severe 30,000 km;
   (diesel) drive belts 160,000 km/72 mo, timing chain CVT 160,000 km / MT
   300,000 km, fuel filter 30,000 km. Generation (T32, ~2014–2021) inferred from
   the engine lineup; the PDF itself is undated.

4. **Nissan South Africa — Qashqai Periodic Maintenance schedule (PDF)** (Grade A)
   `https://www.nissan.co.za/content/dam/Nissan/za/Maintenance/Qashqai.pdf`
   Full normal + severe tables across four engines (1.2T petrol HRA2, 1.5 diesel
   K9K, 1.6 diesel R9M, 1.6T petrol MR16DDT). Backs, per engine: oil & filter
   (1.2T 15,000 km/12 mo severe 5,000 km; 1.5 dsl 30,000 km/12 mo severe
   15,000 km; 1.6T 10,000 km/12 mo); iridium plugs 60,000 km (1.2T) /
   100,000 km (1.6T); coolant first 150,000 km then 75,000 km (150,000-km first
   family) or first 160,000 km then 80,000 km (1.6T); brake fluid 30,000 km/24 mo
   (severe 10,000–15,000 km); air filter 30,000 km (NA) / 40,000 km (1.6T);
   1.5 dsl timing belt & drive belt 90,000 km/48 mo, fuel filter 30,000 km/12 mo.
   Generation (J11, ~2014–2021) inferred from the engine lineup; PDF undated.

### Honda

5. **Honda (UK) online Owner's Manual — Prelude 2026, Maintenance schedule page** (Grade A, cabin filter Grade C)
   `https://manuals.honda.co.uk/prelude/2026/details/67973c83ca02c6-71933317.html`
   The page presents Honda's common maintenance schedule ("applies generally";
   no model year named). Backs: engine oil 10,000 km/12 mo (severe 5,000 km/6 mo);
   air filter 30,000 km; spark plugs 100,000 km; coolant first 200,000 km/10 yr
   then 100,000 km/5 yr; brake fluid every 3 yr (no km); transmission fluid
   150,000 km/6 yr normal, 75,000 km/3 yr severe — **and the same table assigns
   Lebanon (with Jordan, HK, Macao, Morocco, Tunisia) 80,000 km / 4 yr**, which is
   directly market-relevant. Cabin/pollen filter (20,000 km/12 mo) is Grade C —
   positionally implied by the service points, not printed as a number.

### Hyundai

6. **Hyundai New Zealand (myHyundai Care) — "Standard Maintenance Requirements: Petrol Turbo Hybrid Vehicles", V2** (Grade A)
   `https://go.hyundai.co.nz/rs/147-PQU-830/images/3. Petrol-HEV-Turbo-service-requirements Jul 26.pdf`
   Models: Tucson (NX4) HEV MY2025+, Santa Fe (MX5) HEV MY2025+, Palisade (LX3)
   HEV MY2026+. Backs: oil & filter 10,000 km/12 mo (severe = half → 5,000 km/
   6 mo); cabin filter 30,000 km/24 mo; brake fluid 30,000 km/24 mo; air filter
   30,000 km/24 mo; spark plugs 70,000 km/84 mo; coolant (engine & inverter)
   100,000 km/120 mo; hybrid starter-generator belt 40,000 km/48 mo; fuel filter
   maintenance-free.

7. **Hyundai New Zealand (myHyundai Care) — "Standard Maintenance Requirements: Petrol Vehicles (MPI)", V2** (Grade A)
   `https://go.hyundai.co.nz/rs/147-PQU-830/images/1. Petrol-MPI Service Requirements.pdf`
   Models: Kona (SX2), Venue (QX), Tucson (NX4) Series II. Backs: oil & filter
   15,000 km/12 mo (severe = half → 7,500 km/6 mo); cabin filter 30,000 km/24 mo;
   brake fluid 30,000 km/24 mo; air filter 45,000 km/36 mo; spark plugs — Venue
   60,000 km/48 mo, Kona & Tucson 150,000 km/120 mo; coolant 150,000 km/120 mo;
   fuel filter maintenance-free.

### Mitsubishi

8. **Mitsubishi Motors Australia — "24MY ZM Outlander Inspection and Maintenance Schedule" (Oct 2023)** (Grade A)
   `https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/24MY-ZM-OUTLANDER-INSPECTION-AND-MAINTENANCE-SCHEDULE-WEB.pdf`
   Backs (2.5 petrol, CVT): oil & filter 15,000 km/12 mo (severe 7,500 km);
   spark plugs 90,000 km/72 mo; air filter 30,000 km/24 mo; brake fluid
   30,000 km/24 mo; CVT fluid 90,000 km (severe/towing 30,000 km/24 mo per
   footnote *3). Coolant omitted — the coolant row's exact km could not be read
   unambiguously from the table (gap).

9. **Mitsubishi Motors Australia — "19MY MR Triton Periodic Inspection and Maintenance Schedule"** (Grade A)
   `https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/TRITON-MY19_Maintenance-Schedule.pdf`
   Full normal + severe. Backs: oil & filter 15,000 km/12 mo (severe 7,500 km);
   timing belt (petrol) 90,000 km; spark plugs (petrol, standard) 45,000 km;
   fuel filter (petrol) 150,000 km/120 mo; coolant (diesel) first 165,000 km/8 yr
   then 105,000 km/5 yr; ATF 195,000 km normal / 90,000 km severe; transfer oil
   90,000 km / 30,000 km; diff oil 75,000 km / 30,000 km.

---

## Coverage summary (what was sourced)

| Make | Models/engines sourced | Normal | Severe |
|------|------------------------|:------:|:------:|
| Toyota | Petrol-hybrid range (S1); general tropical PMS (S2) | ✓ | partial |
| Nissan | X-Trail T32 (2.0/2.5 petrol, 1.6 dsl); Qashqai J11 (1.2T, 1.5 dsl, 1.6 dsl, 1.6T) | ✓ | ✓ |
| Honda | General EU schedule (oil, air, plugs, coolant, brake, trans) | ✓ | partial |
| Hyundai | Tucson/Santa Fe/Palisade HEV; Kona/Venue/Tucson MPI | ✓ | ✓ (= half) |
| Mitsubishi | Outlander ZM (2.5 petrol); Triton MR (petrol & diesel) | ✓ | ✓ |
| **Lexus** | **none** | — | — |
| **Kia** | **none** | — | — |

---

## Gaps (honest, un-padded)

- **Kia — complete gap.** Every accessible route to Kia's official schedules was
  blocked during research: `ownersmanual.kia.com` and `kia.com` return
  Cloudflare 403 to automated clients (confirmed in a real browser too),
  `manualslib.com` is Cloudflare-gated, and the Kia South Africa service-plan PDF
  failed TLS chain verification. Search snippets suggest figures (e.g.
  Smartstream G2.0 plugs 156,000 km, G1.6 T-GDi plugs 78,000 km, coolant first
  ~195,000 km then ~39,000 km/24 mo), but these were **not** confirmed against a
  fetched document and are therefore **not** recorded. Kia shares engines/
  platforms with Hyundai, but per the GOLDEN RULE no Hyundai value was copied
  across. **Action:** obtain a Kia owner's-manual maintenance page or a Kia
  importer service-requirement PDF from a non-Cloudflare host (or manual upload).

- **Lexus — complete gap.** Official Lexus schedules were not reachable: the
  Toyota/Lexus `assets.sia.toyota.com` PDFs block hotlinking (403 via fetch and
  in-browser), and the only official figure surfaced (Lexus Canada brake fluid
  48,000 km / 96,000 km on a 2025 RX) came from a search snippet, not a fetched
  table, so it was not recorded. **Action:** source the Lexus owner's-manual
  scheduled-maintenance log per model (ES, IS, RX, NX, LX).

- **Toyota non-hybrid normal/severe split — partial.** The clean, fully-cited
  normal+severe table obtained is for the petrol-hybrid range (S1). The
  conventional-petrol owner's-manual normal/severe table (per model: Corolla,
  Camry, RAV4, Hilux, Land Cruiser/Prado, Yaris) was not captured from a single
  fetchable document; the Brunei PMS (S2) stands in as a hot-climate schedule.
  Hyundai/Kia/Toyota manual portals that would carry these are Cloudflare-gated.
  **Action:** source per-model Toyota Scheduled Maintenance Guides (the
  `assets.sia.toyota.com` SMGs) via a route that bypasses hotlink protection, or
  manual upload.

- **Honda model-specific tables — partial.** The Honda schedule recorded is
  Honda's common/general owner's-manual schedule (via the Prelude 2026 OM page).
  Model-specific confirmation for the volume sellers in Lebanon (Civic, Accord,
  CR-V, Jazz/Fit) was not separately captured — `techinfo.honda.com` OM PDFs
  failed TLS verification. The general figures are expected to apply, but
  per-model confirmation is pending. Honda's Maintenance Minder (algorithmic oil
  life) also overrides the fixed oil interval on many models.

- **Nissan sedans/large models — not covered.** Strong SUV coverage (X-Trail,
  Qashqai) via Nissan SA PDFs, but popular Lebanon sedans/trucks (Sunny/Almera,
  Sentra, Altima, Patrol, Navara) were not fetched. Nissan SA hosts similar
  per-model PDFs; **action:** fetch them the same way (they download cleanly).

- **Mitsubishi — coolant on Outlander ZM** could not be read unambiguously from
  the table and was omitted. Other popular models (Pajero/Montero, ASX, Eclipse
  Cross, Lancer, Mirage/Attrage) were not captured; Mitsubishi AU hosts their
  schedules on the same CDN and they download cleanly. **Action:** fetch those.

- **General:** a few long-life-coolant "first X then every Y" items and the
  Nissan 1.6T brake-fluid row carried ambiguous month/km cells; only the
  unambiguous values were recorded.
