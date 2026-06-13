-- Siyyarte — Source Registry refinements after Phase-3 Chinese discovery
BEGIN;
-- BYD: official GCC owner-manual TEXT PDFs confirmed fetchable (upgrade from Blocked_OCR)
UPDATE source_registry SET status='Verified_A', source_type='Owner Manual PDF (text-layer)', access_method='web_fetch PDF (page-range)',
  base_url='https://www.byd.com/content/dam/byd-site/mea-public/after-sales/manual/gcc/BYD_<MODEL>_Owner''s_Manual.pdf',
  known_limitations='GCC text PDFs confirmed (Sealion 7, Seal 7 DM-i, etc.); large -> fetch by page range. Capacities in text (not images as earlier feared).'
 WHERE source_reg_id='SRC-BYD-MEA';
-- MG: official ME portal -> scene7 text PDFs confirmed (upgrade)
UPDATE source_registry SET status='Verified_A', access_method='web_fetch PDF (scene7) + ME portal',
  base_url='https://www.mgmotor.me/ownership/mg-owners-manual/ -> s7ap1.scene7.com/is/content/mgmotor/...pdf',
  known_limitations='Official scene7 PDFs are plain text; ME interval 10,000 km/6mo (ICE/HEV), 25,000 km/12mo (BEV).'
 WHERE source_reg_id='SRC-MG-ME';
-- GAC confirmed Verified_A (intervals); capacities still OCR
UPDATE source_registry SET known_limitations='Warranty & Maintenance manual = full schedule in TEXT (Grade A, incl. >35C severe rule). Owner-manual CAPACITY tables = images (OCR).'
 WHERE source_reg_id='SRC-GAC-SAUDI';
-- Geely: official KSA service-cost text (aggregate intervals only)
UPDATE source_registry SET reliability_grade='A', status='Verified_B',
  base_url='https://geelyksa.com/service-cost/', source_type='Service interval page (HTML text)',
  known_limitations='Official KSA page: interval 10,000 km/12mo; fuel filter 30,000 km. Aggregate only (no item-level table / capacities). Owner-manual PDF not on official ME site.'
 WHERE source_reg_id='SRC-GEELY';
-- Jetour: official KSA service-item sheet found (text)
UPDATE source_registry SET reliability_grade='A', status='Verified_B', source_type='Service-item sheet PDF (text)',
  base_url='https://www.jetourksa.com/static/pdfs/jetor-sheet.pdf',
  known_limitations='Official per-variant maintenance ITEM list (replace/inspect codes) in text. Per-item intervals are a visual grid (not text) -> partial. Owner manual only on aggregators (rejected).'
 WHERE source_reg_id='SRC-JETOUR';
-- Chery: official page exists, JS-only -> browser
UPDATE source_registry SET reliability_grade='A', status='Blocked_OCR',
  base_url='https://cheryqatar.com/owner-manual',
  known_limitations='Official Qatar/Kuwait owner-manual pages exist but JS-rendered (PDF hrefs not in static HTML) -> browser. Aggregator PDFs rejected.'
 WHERE source_reg_id='SRC-CHERY';
COMMIT;
