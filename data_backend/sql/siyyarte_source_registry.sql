-- =====================================================================
-- Siyyarte — SOURCE REGISTRY + VERIFICATION FRAMEWORK (core platform asset)
-- =====================================================================
BEGIN;

-- ---------- 5-level verification framework ----------
CREATE TYPE verification_level AS ENUM (
  'Verified_A',     -- Official source AND manually verified (read from doc)
  'Verified_B',     -- Official source available but pending manual verification
  'Blocked_OCR',    -- Official source exists but needs OCR/browser extraction (image-only PDF)
  'Blocked_Login',  -- Official source exists but requires authentication
  'Unavailable'     -- No official source currently identified
);

-- ---------- Source Registry (reusable pipeline catalogue) ----------
CREATE TABLE source_registry (
    source_reg_id    TEXT PRIMARY KEY,        -- e.g. 'SRC-HYUNDAI-OM'
    oem              TEXT NOT NULL,
    pipeline_name    TEXT NOT NULL,
    base_url         TEXT NOT NULL,
    source_type      TEXT NOT NULL,           -- Owner Manual (HTML) / Spec PDF / Catalogue PDF / Specs page / Approval sheet
    reliability_grade confidence_grade NOT NULL,  -- A/B/C/D for data this pipeline yields
    region           TEXT NOT NULL,           -- GCC / KSA / ME / EC(Except Europe) / Global
    access_method    TEXT NOT NULL,           -- web_fetch HTML / web_fetch PDF / browser+OCR / login-gated
    data_types       TEXT NOT NULL,           -- which fields this pipeline yields
    known_limitations TEXT,
    extraction_process TEXT,
    last_verified    DATE NOT NULL,
    status           verification_level NOT NULL
);

INSERT INTO source_registry VALUES
('SRC-HYUNDAI-OM','Hyundai','Hyundai Owner Manual Web-Help','https://ownersmanual.hyundai.com/full_webhelp/<MODEL>/<YEAR>/en_GN/','Owner Manual (HTML web-help)','A','GCC (en_GN)','web_fetch HTML by topic id',
 'Engine oil grade+capacity, coolant type+capacity, ATF/DCT fluid+capacity, brake fluid, differential oil, fuel tank; per-engine','Spark/timing/RON/intervals sit in separate maintenance sub-chapter (extract separately); model/year/proj codes vary',
 '1) Resolve MODEL(proj code)/YEAR; 2) en_GN = GCC English; 3) fetch "Recommended lubricants & capacities" topic; 4) fetch "Maintenance schedule" topic for intervals; 5) record per engine.','2026-06-12','Verified_A'),
('SRC-KIA-OM','Kia','Kia Owner Manual Web-Help','https://ownersmanual.kia.com/docview/webhelp/doc/<DOC-ID>/topics/','Owner Manual (HTML web-help)','A','GCC / Middle East','web_fetch HTML by topic',
 'Engine oil grade+capacity, coolant type+capacity, ATF fluid+capacity, brake/clutch fluid, fuel tank; explicit "For Middle East" rows','Picanto absent from Aljabr dealer lineup but present in global doc; doc-id discovery needed per model',
 '1) Find DOC-ID for model; 2) fetch chapter "Recommended lubricants & capacities"; 3) prefer "For Middle East" value rows; 4) fetch spark/schedule chapters separately.','2026-06-12','Verified_A'),
('SRC-MAZDA-OM','Mazda','Mazda Online Owner Manual (EC market)','https://owners-manual.mazda.com/gen/en/<MODEL>/<CODE>/contents/<SECTIONID>.html','Owner Manual (HTML)','A','EC = Except Europe (covers GCC/Levant; names Lebanon)','web_fetch HTML by section id',
 'Capacities (oil/coolant/ATF/diff), coolant type, brake/spark intervals, fuel tank, tyres, octane (per-country incl. Lebanon), service intervals — most COMPLETE pipeline','Some viscosity charts are PNG images (value still cited elsewhere); section ids vary by model',
 '1) Pick MODEL+CODE (EC market); 2) Capacities=...10020104; Scheduled Maint=...07020102; Fuel/octane=...04040101; Tyres=...10020109; 3) read values directly.','2026-06-12','Verified_A'),
('SRC-TOYOTA-KSA','Toyota','Toyota Saudi Arabia Full-Specs','https://www.toyota.com.sa/en/vehicles/<MODEL>/full-specs','Specs page (HTML)','A','GCC (KSA)','web_fetch HTML',
 'Engine code/output/torque, transmission, drivetrain, fuel-tank, tyre sizes, recommended octane, dimensions','NO fluid capacities or service intervals (owner manual needed for those); slug per model',
 '1) Resolve model slug; 2) fetch full-specs; 3) record engine/output/tank/tyre/octane; 4) flag fluids/intervals as owner-manual pending.','2026-06-12','Verified_A'),
('SRC-LEXUS-KSA','Lexus','Lexus Saudi Arabia Specs','https://www.lexus.com.sa/en/<MODEL>','Specs page (HTML)','A','GCC (KSA)','web_fetch HTML',
 'Engine/output/torque, transmission, fuel-tank, octane, tyres','No fluid capacities/intervals (owner manual needed)',
 'Same as Toyota KSA pipeline; record engine/tank/octane, flag fluids pending.','2026-06-12','Verified_A'),
('SRC-NISSAN-ME','Nissan','Nissan Middle East Catalogues','https://www-europe.nissan-cdn.net/content/dam/Nissan/nissan_middle_east/brochures/LIB/<CATALOGUE>.pdf','Catalogue PDF','A','GCC / ME','web_fetch PDF',
 'Engine code/output/torque, transmission, fuel-tank, tyre, dimensions','NO maintenance/fluid section in catalogues (owner manual not published online; QRG only) — capacities Unavailable via this pipeline',
 '1) Find ME catalogue PDF; 2) read Technical Specs pages; 3) record engine/tank/tyre; 4) fluids = Unavailable here (need owner manual).','2026-06-12','Verified_A'),
('SRC-RENAULT-QA','Renault','Renault Qatar (Gulf) Specs','https://www.renault.qa/cars/<MODEL>/engines.html','Specs page (HTML)','A','GCC (Qatar)','web_fetch HTML',
 'Engine code/displacement/output, transmission, dimensions','Fluids/intervals pending owner manual; GCC generation can differ from EU',
 'Fetch engines/specs pages; record engine/output; flag fluids pending.','2026-06-12','Verified_A'),
('SRC-MITSU-HABTOOR','Mitsubishi','Mitsubishi Al-Habtoor (UAE) / Saudi Tech Specs PDFs','https://habtoormotors.com/mitsubishi/.../<MODEL>-Technical-Specs.pdf','Spec PDF','A','GCC (UAE/KSA)','web_fetch PDF',
 'Engine code/output, transmission, fuel-tank, tyres, battery type, octane','Fluids/intervals pending owner manual; ASEAN spec lists differ on emissions trim',
 'Fetch dealer technical-specs PDF; record engine/tank/tyre/battery/octane; flag fluids pending.','2026-06-12','Verified_A');

COMMIT;
