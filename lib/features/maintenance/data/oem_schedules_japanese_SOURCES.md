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

## Sources added in the gap-fill pass

### Nissan (sedans / trucks)

10. **Nissan South Africa — Almera 1.5 Petrol Periodic Maintenance schedule (PDF)** (Grade A)
    `https://www.nissan.co.za/content/dam/Nissan/za/Maintenance/Almera.pdf`
    Downloaded cleanly from the same CDN as X-Trail/Qashqai; parsed with
    `pdftotext -layout` and column positions verified numerically. The Almera is
    the **Sunny** in MENA markets. Full normal + severe. Backs: oil & filter
    15,000 km/12 mo (severe 7,500 km/6 mo); air filter 30,000 km; iridium plugs
    90,000 km ("[R] at specified mileage only", verified under the 90 column);
    coolant first 150,000 km then 75,000 km/48 mo (mixture check 30,000/24 mo);
    brake fluid 30,000 km/24 mo (severe 15,000 km/12 mo); auto transaxle fluid
    severe 30,000 km/24 mo (normal = inspect); fuel filter maintenance-free.

11. **Nissan South Africa — Navara 2.3 Turbo Diesel Periodic Maintenance schedule (PDF)** (Grade A, transfer/diff single-R rows Grade B)
    `https://www.nissan.co.za/content/dam/Nissan/za/Maintenance/Navara.pdf`
    D23 generation. Full normal + severe. Backs: oil & filter 15,000 km/12 mo
    (the severe table does NOT shorten oil for the Navara; oil indicator may call
    it sooner); air filter 30,000 km (clean every 5,000 km); fuel filter replace
    45,000 km (R at 45k/90k; severe 15,000 km/12 mo); coolant first 150,000 km
    then 75,000 km/48 mo; drive belts 240,000 km/120 mo (severe 120,000 km/60 mo);
    timing chain 300,000 km; brake fluid 30,000 km/24 mo (severe 15,000 km/12 mo);
    auto trans fluid severe 30,000 km/24 mo; diff oil 120,000 km normal / 30,000 km
    severe; transfer fluid 105,000 km; cabin filter 15,000 km. (NP300, NP200, Juke,
    Micra PDFs also exist on the same CDN but were not in scope.)

### Mitsubishi (additional models)

12. **Mitsubishi Motors Australia — "21MY LA Mirage Maintenance Schedule"** (Grade A)
    `https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/MIRAGE-21MY_Maintenance-Schedule.pdf`
    This older template prints clean "R: Every X" text. Backs (petrol): oil &
    filter 15,000 km/12 mo (severe 7,500 km); platinum/iridium plugs 90,000 km;
    coolant first 165,000 km/8 yr then 105,000 km/5 yr; fuel filter 150,000 km/
    10 yr; manual trans 195,000 km (severe 90,000 km); CVT/ATF 90,000 km (severe
    45,000 km). The densely-packed air-filter/brake-fluid column rows were not
    legible from the text layer and were omitted. **The Attrage sedan shares the
    LA platform but is not named in this document, so it is not recorded.**

13. **Mitsubishi Motors Australia — "24MY QG Pajero Sport Maintenance Schedule"** (Grade A)
    `https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/24MY-QG-PAJERO-SPORT-MAINTENANCE-SCHEDULE-WEB.pdf`
    Diesel (common rail). Only the clean same-line rows recorded: oil & filter
    15,000 km/12 mo (severe 7,500 km); coolant first 165,000 km/8 yr then
    105,000 km/5 yr. (New-template column rows illegible from the text layer.)

14. **Mitsubishi Motors Australia — "22MY NX Pajero Maintenance Schedule"** (Grade A)
    `https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/22MY-NX-Pajero-service-schedule.pdf`
    Full-size Pajero/Montero, 3.2 diesel. Columns fully collapsed in the text
    layer; only explicit "R: Every X" rows recorded: oil & filter 15,000 km/12 mo
    (severe 7,500 km); ATF 195,000 km normal / 90,000 km severe.

15. **Mitsubishi Motors Australia — "24MY XD ASX Maintenance Schedule"** (Grade A, CVT Grade B)
    `https://media.adtorqueedge.com/mitsubishi-au/maintenance-schedule/pdfs/24MY-XD-ASX-INSPECTION-AND-MAINTENANCE-SCHEDULE-WEB.pdf`
    Petrol, CVT. Oil & filter 15,000 km/12 mo (severe 7,500 km); CVT fluid
    40,000 km ("R: Every 40,000km"; corroborated by the 23MY XD schedule).
    Spark-plug and coolant rows not legible, omitted.

16. **Outlander ZM coolant — still a gap.** The 24MY ZM Outlander PDF's new
    template renders the coolant row with detached markers (`Change engine
    coolant *1 *2` with no legible km in the text layer), so the previously-noted
    omission stands. Not guessed, not copied from the Mirage/Pajero petrol value.

### Kia (official owner's manuals via Internet Archive OCR — Grade B)

> Every Kia OEM host (`ownersmanual.kia.com`, `kia.com`) and third-party
> aggregator (ManualsLib, manualmachine) was Cloudflare/WAF-blocked to BOTH
> plain fetch and a fully-rendered in-app browser (confirmed this pass:
> "Attention Required! | Cloudflare", "Just a moment…" that never cleared).
> `kia.co.za/maintenance-schedule` rendered but its data was placeholder
> (100 km/206 km/302 km options). The genuine Kia owner's manuals — with full
> OCR text — were reachable on the Internet Archive "Car Service Manuals"
> collection. Because that is an OCR mirror, not Kia's own host, these are
> **Grade B**; OCR-ambiguous values were omitted. **No Hyundai value was copied.**

17. **Kia 2015 Sorento (UM) Owner's Manual** — `https://archive.org/details/car-service-manuals-kia-2015-sorento`
    Gasoline "Except Europe" normal + full severe table. Normal: oil & filter
    12,000 km/12 mo; coolant first 96,000 km/60 mo then 48,000 km/24 mo; drive
    belts first 96,000 km then 24,000 km; manual trans fluid inspect 64,000 km.
    Severe: oil & filter 6,000 km/6 mo; ATF 96,000 km; manual trans 120,000 km;
    transfer-case & rear-axle oil (AWD) 120,000 km. Spark-plug normal interval was
    only positionally listed (OCR) → omitted.

18. **Kia 2016 Sportage (QL) Owner's Manual** — `https://archive.org/details/car-service-manuals-kia-2016-sportage`
    Normal only (the severe table's columns were OCR-jumbled → omitted). Oil &
    filter 2.4 GDI 12,000 km/12 mo; 1.6 T-GDI first 5,000 km then 8,000 km/6 mo;
    air cleaner every 48,000 km (R at 48/96/144/192).

19. **Kia 2016 Forte/Cerato (YD) Owner's Manual** — `https://archive.org/details/car-service-manuals-kia-2016-forte`
    Normal + severe. Oil & filter MPI/GDI 12,000 km/12 mo (severe 6,000 km/6 mo);
    1.6 Turbo GDI first 5,000 km then 8,000 km/6 mo (severe 5,000 km/6 mo);
    coolant first 192,000 km/120 mo then 48,000 km/24 mo; ATF severe 96,000 km;
    manual trans severe 120,000 km.

20. **Kia 2016 Rio (UB) Owner's Manual** — `https://archive.org/details/car-service-manuals-kia-2016-rio`
    Oil & filter normal 12,000 km (listed at the 12,000 km service; the oil-
    specific month figure was not separately printed, so months omitted); severe
    6,000 km/6 mo; coolant first 192,000 km/120 mo then 48,000 km/24 mo.

### Lexus (official Warranty & Services Guide via Internet Archive — Grade B)

> `assets.sia.toyota.com` (the L-MMS warranty/maintenance PDFs) returns S3
> `AccessDenied` to plain fetch AND to a fully-rendered in-app browser — a
> WAF/IP block, not a referer check, so unreachable. The Lexus US owner's
> manuals that ARE on the Archive defer all intervals to the separate guide.
> Exactly one Lexus guide with the schedule was found on the Archive:

21. **Lexus 2016 NX 200t Warranty and Services Guide** — `https://archive.org/details/manuals-plus-2016-lexus-nx-200t-warranty-and-services-guide-11e5a98e`
    US Scheduled Maintenance Log (miles; km are the guide's own conversions) +
    Special Operating Conditions (= severe for Lebanon). Oil & filter 16,000 km
    (10,000 mi)/12 mo normal, 8,000 km (5,000 mi)/6 mo special-ops; spark plugs
    64,000 km (40k & 80k mi); brake fluid 48,000 km (30k & 60k mi); engine air
    filter 48,000 km; cabin filter 32,000 km (20k/40k/60k/80k mi); transmission
    fluid 96,000 km (60k mi); coolant first 160,000 km (100k mi), SLLC thereafter.

---

## Coverage summary (what was sourced)

| Make | Models/engines sourced | Normal | Severe |
|------|------------------------|:------:|:------:|
| Toyota | Petrol-hybrid range (S1); general tropical PMS (S2) | ✓ | partial |
| Nissan | X-Trail T32; Qashqai J11; **Almera/Sunny (1.5)**; **Navara (2.3 TD)** | ✓ | ✓ |
| Honda | General EU schedule (oil, air, plugs, coolant, brake, trans) | ✓ | partial |
| Hyundai | Tucson/Santa Fe/Palisade HEV; Kona/Venue/Tucson MPI | ✓ | ✓ (= half) |
| Mitsubishi | Outlander ZM; Triton MR; **Mirage LA**; **Pajero Sport QG**; **Pajero NX**; **ASX XD** | ✓ | ✓ |
| **Lexus** | **NX 200t (2016)** — Grade B | ✓ | ✓ (special-ops) |
| **Kia** | **Sorento UM; Sportage QL; Cerato/Forte YD; Rio UB** — Grade B | ✓ | ✓ (Sportage normal only) |

---

## Gaps (honest, un-padded)

- **Kia — PARTIALLY FILLED (gap-fill pass).** Sorento (UM), Sportage (QL),
  Cerato/Forte (YD) and Rio (UB) are now recorded at **Grade B** from the genuine
  Kia owner's manuals (OCR full text on the Internet Archive) — see sources 17–20.
  The OEM/aggregator hosts remain Cloudflare/WAF-blocked (re-confirmed this pass
  in a fully-rendered browser), and `kia.co.za`'s schedule tool served only
  placeholder data. **Still gaps:** Picanto and Seltos (not present in the
  reachable US manual collection); the Sportage severe table (OCR columns not
  legibly aligned). No Hyundai value was copied across. **Action:** obtain Kia
  Picanto/Seltos manuals and the Sportage severe table from a legible source.

- **Lexus — PARTIALLY FILLED (gap-fill pass).** NX 200t (2016) is now recorded
  at **Grade B** from the official Lexus Warranty & Services Guide (Internet
  Archive, source 21), including the Special Operating Conditions (severe)
  schedule. `assets.sia.toyota.com` returns S3 `AccessDenied` to both fetch and a
  rendered browser (WAF/IP block), and the Lexus US owner's manuals on the
  Archive defer all intervals to the separate guide — only the NX guide was found
  there. **Still gaps:** ES, IS, RX, LX scheduled-maintenance logs. **Action:**
  source each remaining model's Warranty & Services Guide (or a non-US Lexus
  manual that embeds the schedule) from a reachable host / manual upload.

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

- **Nissan sedans/trucks — PARTIALLY FILLED.** Almera/Sunny (1.5) and Navara
  (2.3 TD) are now recorded (Grade A) from Nissan SA PDFs (sources 10–11).
  **Still gaps:** Sentra, Altima and Patrol are **404 on the Nissan SA CDN**
  (not hosted there). **Action:** source those from another Nissan importer.

- **Mitsubishi — MOSTLY FILLED.** Mirage (LA), Pajero Sport (QG), Pajero (NX)
  and ASX (XD) are now recorded (sources 12–15). **Still gaps:** the Outlander ZM
  coolant row (new-template PDF renders it with detached markers — source 16);
  Eclipse Cross and Lancer were not captured. Attrage shares the Mirage LA
  platform but is a distinct model and was **not** copied across. **Action:**
  capture Outlander coolant + Eclipse Cross/Lancer from a legible render.

- **General:** a few long-life-coolant "first X then every Y" items and the
  Nissan 1.6T brake-fluid row carried ambiguous month/km cells; only the
  unambiguous values were recorded.
