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

## Sources added in gap-fill pass 2

**Sourcing breakthrough this pass:** the Lexus/Toyota Warranty-&-Services guides on
`assets.sia.toyota.com` return **HTTP 403** live (WAF/IP block, re-confirmed), but the
**genuine publisher PDFs** (native text — not OCR; they column-align with
`pdftotext -table`) are cached on the **Wayback Machine** and were read directly from
there via the `…/web/<timestamp>id_/<url>` raw-original form. Toyota RAV4 fetched live
from `toyota.com`. Mitsubishi AU PDFs fetch cleanly from `media.adtorqueedge.com`.
Nissan Altima/Sentra come from Nissan USA's official per-model schedule tool.

> Lexus/Toyota/Nissan intervals are published in **miles**; km shown are the OEM's own
> **1 mi = 1.6 km** convention (Nissan prints "7,500 miles (12,000 km)"; Lexus prints
> "10,000 mi (16,000 km)"). The source mileage is kept in each interval's note.

### Mitsubishi (Grade A)

22. **Mitsubishi AU — "20MY YA Eclipse Cross Maintenance Schedule"** (MY19 identical)
    `…/pdfs/ECLIPSE-CROSS-20MY-Maintenance-Schedule.pdf`
    1.5T petrol, CVT. Oil 15,000 km/12 mo (severe 7,500 km); spark plugs 90,000 km;
    **coolant first 195,000 km/10 yr then 120,000 km/6 yr** (value confirmed on its own
    "Replace engine coolant" row with `pdftotext -table` — it is NOT the air-cleaner
    value, which the plain text layer mis-rowed); engine air filter 45,000 km (Grade C,
    4 positional column markers, corroborated by the Lancer's clean 6-marker row); brake
    fluid 30,000 km/24 mo (7 even column markers); fuel filter 150,000 km/10 yr; CVT
    90,000 km (severe 45,000 km); transfer 75,000 km (severe 45,000 km); diff 90,000 km
    (severe 45,000 km).

23. **Mitsubishi AU — "MY17 CF Lancer Maintenance Schedule"** `…/pdfs/LANCER-MY17_Maintenance-Schedule.pdf`
    2.0/2.4 petrol. Oil 15,000 km/12 mo (severe 7,500 km); spark plugs 90,000 km;
    coolant first 120,000 km/8 yr then 75,000 km/5 yr; air filter 45,000 km (6 even
    markers); brake fluid 30,000 km/24 mo (10 even markers); cabin (air purifier) filter
    15,000 km; fuel filter 150,000 km/10 yr; manual trans 195,000 km (severe 90,000 km);
    auto/CVT 90,000 km (severe 45,000 km).

24. **Mitsubishi AU — "22MY & 23MY ZM Outlander Maintenance Schedule"** `…/pdfs/22MY-ZM-Outlander-service-schedule.pdf`
    **Fills the Outlander ZM coolant gap.** 2.5 PR25 petrol. Both model years (same ZM
    generation as the 24MY entry) print **coolant first 150,000 km/8 yr then 75,000 km/
    4 yr** and air cleaner "R: 30,000 km/24 months" cleanly via `pdftotext -table`.

### Lexus (Grade A — genuine Warranty & Services Guides via Wayback Machine)

25. **Lexus 2025 RX 350 W&S Guide** (`L-MMS-25RX350`, 2.4T) — oil 16,000 km (10k mi)/12 mo
    normal, 8,000 km (5k mi)/6 mo special-ops; spark plugs 64,000 km (40k mi); brake
    fluid 48,000 km (30k mi); engine air filter 48,000 km (30k mi); cabin filter
    16,000 km (10k mi); **coolant first 160,000 km (100k mi)/120 mo then 80,000 km
    (50k mi)/60 mo** (footnote). ATF/diff/transfer inspect-only normal, replace under
    towing (not recorded as intervals).

26. **Lexus 2025 ES 250/ES 350 W&S Guide** (`L-MMS-25ES250ES350`, NA) — oil 16,000 km/
    12 mo (severe 8,000 km/6 mo); spark plugs 192,000 km (120k mi); brake fluid 48,000 km;
    engine air filter 48,000 km; cabin filter 16,000 km; coolant first 160,000 km/120 mo
    then 80,000 km/60 mo.

27. **Lexus 2023 LX 600 W&S Guide** (`L-MMS-23X600`, 3.5TT, non-hybrid) — **oil & coolant
    only.** Oil 16,000 km/12 mo (severe 8,000 km/6 mo); coolant first 160,000 km (100k
    mi)/120 mo then 80,000 km (50k mi). The dense two-column maintenance pages did not
    column-align unambiguously for brake fluid / air filters / spark plugs / transfer —
    left as an honest gap.

### Toyota non-hybrid (Grade A — per-model Warranty & Maintenance Guides)

28. **Toyota 2023 RAV4 W&M Guide** (2.5 A25A; fetched live from toyota.com) — oil
    16,000 km (10k mi)/12 mo (0W-16 fill; 0W-20 → 5k mi), severe 8,000 km (5k mi)/6 mo;
    engine air filter 48,000 km (30k mi); cabin filter 48,000 km (30k mi); spark plugs
    192,000 km (120k mi); **coolant first 160,000 km (100k mi)/120 mo then 80,000 km
    (50k mi)/60 mo**; ATF inspect normal / replace 96,000 km (60k mi) under towing.

29. **Toyota 2024 Camry W&M Guide** (2.5 A25A, non-hybrid; via Wayback) — oil as RAV4;
    engine air filter 48,000 km; **spark plugs 96,000 km (listed at 60k AND 120k mi —
    recorded as read; differs from RAV4/Corolla's 120k)**; coolant 160k→80k km; ATF
    severe 96,000 km. Cabin-filter milestone not legible on two-column pages → omitted.

30. **Toyota 2024 Corolla W&M Guide** (2.0 M20A; via Wayback) — oil as RAV4; engine air
    filter 48,000 km; cabin filter 48,000 km; spark plugs 192,000 km (120k mi); coolant
    160k→80k km; ATF severe 96,000 km.

### Nissan (Grade A — Nissan USA official schedule tool, US-market)

31. **Nissan 2022 Altima** (`maintenance-schedules.nissanusa.com/.../2022/altima/`) —
    2.5L: oil 16,000 km (10k mi)/12 mo; 2.0T: 12,000 km (7.5k mi). Spark plugs 168,000 km
    (105k mi); **coolant first 168,000 km (105k mi)/84 mo then 120,000 km (75k mi)/60 mo**;
    CVT inspect normal / replace 96,000 km (60k mi) severe; brake fluid 32,000 km (20k mi)/
    24 mo normal, 16,000 km (10k mi)/12 mo severe; engine air filter 48,000 km (30k mi).

32. **Nissan 2019 Sentra** (`…/2019/sentra/`, B17, 1.8 MRA8) — oil 8,000 km (5k mi)/6 mo;
    spark plugs 168,000 km (105k mi); coolant first 168,000 km/84 mo then 120,000 km/60 mo;
    CVT inspect normal / replace 96,000 km (60k mi) severe; engine air filter 48,000 km.

---

## Sources added in gap-fill pass 3

Routes: official per-model schedule **tools** (Infiniti USA, sibling of the Nissan
tool), a **Genesis Canada** metric schedule PDF, genuine **Kia Australia** and
**Nissan NZ** / **Toyota NZ** documents. Infiniti is mile-based (1 mi = 1.6 km, source
miles in notes); Genesis/Kia/Nissan/Toyota here are metric-native.

### Infiniti (Grade A — Infiniti USA schedule tool, US-market)

33. **Infiniti 2022 Q50** (`maintenance-schedules.infinitiusa.com/.../2022/q50/`, 3.0TT V6
    VR30DDTT) — oil 16,000 km (10k mi)/12 mo; spark plugs 168,000 km (105k mi)/126 mo;
    **coolant first 168,000 km (105k mi)/84 mo then 120,000 km (75k mi)/60 mo**; brake
    fluid 32,000 km (20k mi)/24 mo normal, 16,000 km (10k mi)/12 mo severe. No scheduled
    transmission-fluid component (lifetime fill).

34. **Infiniti 2022 QX60** (`.../2022/qx60/`, 3.5 V6 VQ35DD) — oil 16,000 km (10k mi)/
    12 mo; plugs 168,000 km/126 mo; coolant first 168,000 km/84 mo then 120,000 km/60 mo;
    brake fluid 32,000 km/24 mo normal, 16,000 km/12 mo severe.

35. **Infiniti 2022 QX80** (`.../2022/qx80/`, 5.6 V8 VK56VD) — **oil 12,000 km (7.5k mi)/
    6 mo normal, 8,000 km (5k mi)/6 mo severe**; plugs 168,000 km (105k mi)/84 mo; coolant
    first 168,000 km/84 mo then 120,000 km/60 mo; brake fluid 48,000 km (30k mi)/24 mo
    normal, 16,000 km (10k mi)/12 mo severe.

### Genesis (Grade A — Genesis Canada "Service Maintenance Schedules", metric)

36. **Genesis G70 / G80 / GV70 / GV80 (gasoline)** —
    `genesis.com/.../Genesis-Service-Maintenance-Schedules-EN.pdf`
    The doc lists each gasoline model with the SAME long-interval figures, recorded once
    as a range: engine oil 10,000 km / 12 mo (every service); **spark plugs 70,000 km /
    84 mo**; LSD differential oil (AWD) 60,000 km / 72 mo. Coolant and brake-fluid
    intervals are stated only for the EV variants in this doc → gap for the gasoline
    models. EV variants excluded. No Hyundai value copied.

### Kia Picanto (Grade A — genuine Kia Australia owner's manual)

37. **Kia Picanto MY24 (AU/NZ, 1.2 MPI)** —
    `kia.com/.../owners-manuals/picanto/kia-picanto-owners-manual-my24.pdf`
    The manual embeds a subset font with a constant −31 byte offset that garbles
    `pdftotext`; **PyMuPDF decodes it natively** (digits intact). Normal: oil 15,000 km/
    12 mo; spark plugs 150,000 km; **coolant first 180,000 km/120 mo then 30,000 km/
    24 mo**; air cleaner 45,000 km; cabin filter 30,000 km. Severe (Non-Turbo, conditions
    A–L): oil 7,500 km/6 mo; manual trans 120,000 km; auto trans 90,000 km; plugs "more
    frequently".

### Nissan Patrol (Grade A/B — Nissan NZ capped-price service, Y62 V8)

38. **Nissan Patrol Y62 (VK56VD V8)** —
    `nissan.co.nz/.../capped-price-service/Y62 - Patrol Capped Price Service.pdf`
    Normal 10,000 km/12 mo schedule. Oil 10,000 km/12 mo; **coolant first 160,000 km/
    96 mo then 80,000 km/48 mo** (Note-3; mixture check every 40,000 km/24 mo); brake
    fluid 40,000 km/24 mo; spark plugs 100,000 km (Grade B, single R); air cleaner and
    differential oil 40,000 km (Grade B, counted R markers). ATF/transfer replacement km
    are in un-captured notes → gap.

### Toyota conventional petrol (Grade A/C — Toyota NZ make-wide sheet)

39. **Toyota NZ "Service Requirements: Petrol Vehicles" (Sept 2023)** —
    `toyota.co.nz/globalassets/owners/servicing-your-toyota/toyota-petrol-service-requirements.pdf`
    Make-wide conventional-petrol schedule (so **Hilux / Land Cruiser / Prado petrol**
    fall under it), normal conditions. Only the unambiguous items recorded: engine oil
    15,000 km/12 mo (every service, Grade A); engine coolant "then every 75,000 km/5 yr"
    (Grade A for the subsequent interval; first ≈150,000 km positionally, Grade C).
    Spark-plug km is "at specified Kms only" (not printed) and the A–G coded brake/ATF/
    transfer grid was not recorded → per-model gaps remain.

---

## Sources added in gap-fill pass 4 (OLX-Lebanon market scan)

Targets actively listed for sale in Lebanon. Nissan via the USA schedule tool
(miles, 1 mi = 1.6 km); Toyota Tacoma live from toyota.com; Lexus LX non-oil items
re-read from the same guide with column-aware PyMuPDF + `pdftotext -table`.

40. **Nissan 2023 Rogue** (`maintenance-schedules.nissanusa.com/.../2023/rogue/`,
    1.5 VC-Turbo 3-cyl KR15DDT — the **US sibling of the X-Trail**, T33). Oil
    12,000 km (7.5k mi)/12 mo; **spark plugs 96,000 km (60k mi)/96 mo** (turbo —
    shorter than the NA Nissans' 105k mi); coolant first 168,000 km (105k mi)/84 mo
    then 120,000 km (75k mi)/60 mo; brake fluid 24,000 km (15k mi)/24 mo normal,
    12,000 km (7.5k mi)/12 mo severe; CVT inspect normal / replace 96,000 km
    (60k mi) severe.

41. **Nissan 2023 Kicks** (`.../2023/kicks/`, 1.6 NA HR16DE, CVT). Oil 12,000 km
    (7.5k mi)/6 mo normal, 8,000 km (5k mi)/6 mo severe; spark plugs 168,000 km
    (105k mi)/84 mo; coolant first 168,000 km/84 mo then 120,000 km/60 mo; brake
    fluid 48,000 km (30k mi)/24 mo normal, 16,000 km (10k mi)/12 mo severe; CVT
    inspect normal / replace 96,000 km (60k mi)/72 mo severe.

42. **Toyota 2023 Tacoma** (toyota.com, 2.7 I4 2TR-FE / 3.5 V6 2GR-FKS petrol). Oil
    16,000 km (10k mi)/12 mo with factory 0W-20, severe 8,000 km (5k mi)/6 mo;
    engine air filter 48,000 km (30k mi); **spark plugs V6 (2GR-FKS) 96,000 km
    (60k mi)** ("2GR-FKS engine only"; the 2.7 I4 is at the generic 120k-mi
    milestone); coolant first 160,000 km (100k mi)/120 mo then 80,000 km (50k mi)/
    60 mo; ATF inspect normal / replace 96,000 km (60k mi) under towing. Front/rear
    differential & transfer oils are inspect-normal / replace-under-towing (the
    severe replace intervals were not pinned cleanly — not recorded).

43. **Lexus 2023 LX 600 — non-oil items (supplement to source 27).** The previously
    illegible two-column pages were re-read with **column-aware PyMuPDF** (split by
    page-midpoint x) cross-checked against `pdftotext -table`; both agree on the
    30,000 mi service pattern. Brake fluid, engine air filter, cabin air filter and
    transfer case oil all **every 30,000 mi (48,000 km)** (replaced at 30k/60k/90k);
    spark plugs **every 40,000 mi (64,000 km)** (40k/80k, twin-turbo). ATF/diff are
    inspect-normal / replace-under-towing — not recorded.

---

## Coverage summary (what was sourced)

| Make | Models/engines sourced | Normal | Severe |
|------|------------------------|:------:|:------:|
| Toyota | Hybrid range (S1); tropical PMS (S2); non-hybrid RAV4/Camry/Corolla (S28–30); **Tacoma** (S42); make-wide conventional petrol incl. Hilux/LC/Prado (S39) | ✓ | ✓ |
| Nissan | X-Trail; Qashqai; Almera/Sunny; Navara; Altima; Sentra; Patrol Y62; **Rogue (US X-Trail); Kicks** (S40–41) | ✓ | ✓ |
| Honda | General EU schedule (oil, air, plugs, coolant, brake, trans) | ✓ | partial |
| Hyundai | Tucson/Santa Fe/Palisade HEV; Kona/Venue/Tucson MPI | ✓ | ✓ (= half) |
| Mitsubishi | Outlander ZM (coolant filled); Triton; Mirage; Pajero Sport; Pajero; ASX; Eclipse Cross; Lancer | ✓ | ✓ |
| **Lexus** | NX 200t (Grade B); RX 350, ES 250/350, **LX 600 (now incl. non-oil, S43)** (Grade A, Wayback) | ✓ | ✓ (special-ops) |
| **Kia** | Sorento; Sportage; Cerato/Forte; Rio (Grade B); **Picanto JA (Grade A, Kia AU)** (S37) | ✓ | ✓ (Picanto + most) |
| **Infiniti** | **Q50; QX60; QX80** (Grade A, Infiniti USA tool) (S33–35) | ✓ | ✓ (brake/oil) |
| **Genesis** | **G70 / G80 / GV70 / GV80 gasoline** (Grade A, Genesis CA) (S36) | ✓ | — (doc is normal-schedule) |

---

## Gaps (honest, un-padded)

- **Kia — PARTIALLY FILLED (gap-fill pass).** Sorento (UM), Sportage (QL),
  Cerato/Forte (YD) and Rio (UB) are now recorded at **Grade B** from the genuine
  Kia owner's manuals (OCR full text on the Internet Archive) — see sources 17–20.
  The OEM/aggregator hosts remain Cloudflare/WAF-blocked (re-confirmed this pass
  in a fully-rendered browser), and `kia.co.za`'s schedule tool served only
  placeholder data. **Still gaps:** Picanto and Seltos (re-confirmed this pass via
  the archive.org advancedsearch API — the `car-service-manuals-kia-*` collection is
  US-market and lists no Picanto/Seltos, which are not sold in the US); the Sportage
  severe table (OCR columns not legibly aligned). No Hyundai value was copied across.
  **Pass 3:** **Picanto (JA) is now FILLED at Grade A** from the genuine Kia Australia
  owner's manual (source 37, decoded with PyMuPDF). **Still gaps:** **Seltos** (the Kia
  AU owner-manual URL now 404s / has moved; US and UK paths also 404) and the Sportage
  severe table. **Action:** obtain a current Kia Seltos owner's manual (AU/GCC/UK) and
  the Sportage severe table from a legible source.

- **Lexus — MOSTLY FILLED (pass 2).** NX 200t (Grade B, Archive OCR) plus **RX 350,
  ES 250/350 and LX 600 (Grade A)** from the genuine Warranty & Services Guides,
  read via the **Wayback Machine** (the live `assets.sia.toyota.com` host 403s to
  both fetch and a rendered browser, but Wayback caches the real native-text PDFs —
  sources 25–27). **Pass 4:** the LX 600's previously-illegible **non-oil items are
  now FILLED** (source 43) — brake fluid, engine air filter, cabin air filter and
  transfer case oil every 30,000 mi, spark plugs every 40,000 mi — re-read with
  column-aware PyMuPDF + `pdftotext -table`. **Still gaps:** **IS** (no reachable
  guide — all IS snapshots missing from Wayback, live host blocked); LX ATF/diff
  (inspect-normal / replace-under-towing, interval not pinned). **Action:** source an
  IS Warranty & Services Guide from a reachable host / upload.

- **Toyota non-hybrid — MOSTLY FILLED (pass 2).** Non-hybrid **RAV4 (2.5), Camry
  (2.5) and Corolla (2.0)** are now recorded at **Grade A** from the per-model
  Warranty & Maintenance Guides (RAV4 live from toyota.com; Camry/Corolla via
  Wayback — sources 28–30), with normal + Special Operating Conditions. **Still
  gaps:** **Hilux** (not in the US guide lineup) and **Land Cruiser/Prado
  non-hybrid** (the US 2024 Land Cruiser is the 2.4T i-FORCE MAX **hybrid** only;
  the non-hybrid Prado is a MENA/AU model not on the reachable US hosts). **Pass 3:**
  a make-wide Toyota NZ conventional-petrol sheet (source 39) now covers Hilux / Land
  Cruiser / Prado **petrol** for the unambiguous items (oil 15,000 km/12 mo; coolant
  "then every 75,000 km/5 yr"). **Still gaps:** per-model Hilux/LC/Prado spark-plug and
  transmission figures (the sheet is make-wide and prints "spark plugs at specified Kms
  only"). **Action:** source a per-model Hilux/Prado/LC logbook from a Gulf/AU importer.

- **Honda model-specific tables — STILL PARTIAL.** The Honda schedule recorded is
  Honda's common/general owner's-manual schedule (via the Prelude 2026 OM page).
  Model-specific confirmation for the volume sellers in Lebanon (Civic, Accord,
  CR-V, Jazz/Fit) was **not** captured this pass either — Honda does not publish
  the assets.sia-style per-model guide, and `techinfo.honda.com` OM PDFs failed TLS
  verification. The general figures are expected to apply, but per-model
  confirmation is pending. Honda's Maintenance Minder (algorithmic oil life) also
  overrides the fixed oil interval on many models. **Action:** capture Civic/Accord/
  CR-V maintenance from an owner's-manual "Maintenance" section via a reachable host.

- **Nissan sedans/trucks — MOSTLY FILLED (pass 2).** Almera/Sunny and Navara (Grade
  A, Nissan SA) plus **Altima (L34, 2022) and Sentra (B17, 2019)** (Grade A, Nissan
  USA official schedule tool — sources 31–32, US-market). **Pass 3: Patrol Y62 is now
  FILLED** (Grade A/B) from the Nissan NZ capped-price service document (source 38:
  oil 10,000 km/12 mo; coolant first 160,000 km/96 mo then 80,000 km/48 mo; brake fluid
  40,000 km/24 mo; plugs 100,000 km; air cleaner & diff 40,000 km). **Pass 4 (OLX
  scan):** **Rogue (T33, the US X-Trail sibling)** and **Kicks (P15)** added at Grade A
  from the Nissan USA tool (sources 40–41). **Still gaps:** **Magnite** (India/MENA
  small SUV — 404 on the Nissan SA and NZ hosts, absent from the US tool); the Patrol
  ATF/transfer km; a current B18 Sentra (2020+) would be more fleet-relevant than the
  B17 recorded. **Action:** source Magnite from Nissan India / a Gulf importer.

- **Infiniti & Genesis — FILLED (pass 3).** Infiniti Q50, QX60, QX80 (Grade A, Infiniti
  USA schedule tool — sources 33–35) and Genesis G70/G80/GV70/GV80 gasoline (Grade A,
  Genesis Canada schedule — source 36). Residual: Infiniti air-filter/cabin-filter not
  recorded (secondary); Genesis gasoline coolant & brake-fluid intervals are EV-only in
  the CA doc (gap — would need a Genesis owner's manual). EV variants excluded by design.

- **Mitsubishi — FILLED (pass 2).** Mirage, Pajero Sport, Pajero and ASX (sources
  12–15) plus **Eclipse Cross (YA) and Lancer (CF)** (sources 22–23), and the
  **Outlander ZM coolant gap is now filled** from the 22/23MY ZM schedules (source
  24: first 150,000 km/8 yr then 75,000 km/4 yr). Attrage shares the Mirage LA
  platform but is a distinct model and was **not** copied across. The only residual:
  Eclipse Cross air-cleaner is Grade C (positional column markers).

- **General:** a few long-life-coolant "first X then every Y" items and the
  Nissan 1.6T brake-fluid row carried ambiguous month/km cells; only the
  unambiguous values were recorded.
