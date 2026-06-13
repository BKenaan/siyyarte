-- Siyyarte — Source Registry status refinements after Phase-2 pilots
BEGIN;
-- GM & Ford pilots PROVEN (acceptance gate passed)
UPDATE source_registry SET status='Verified_A', last_verified='2026-06-12',
  known_limitations='PROVEN via pilots (Tahoe/Yukon/Explorer/F-150). Large PDFs need in-browser pdf.js parse (web_fetch truncates). US-spec only.'
 WHERE source_reg_id IN ('SRC-GM-OWNERCENTER','SRC-FORD-CATALOG');
-- GAC: intervals Verified_A (warranty manual flowing text); capacities Blocked_OCR (owner-manual image tables)
UPDATE source_registry SET status='Verified_A',
  known_limitations='Maintenance INTERVALS = Grade-A from Warranty & Maintenance manual (flowing text). CAPACITIES/octane/tyre = owner-manual IMAGE tables = Blocked_OCR.',
  data_types='Maintenance intervals (oil/coolant/brake/spark/trans). Capacities require OCR.'
 WHERE source_reg_id='SRC-GAC-SAUDI';
-- BYD: source confirmed; specs are image tables
UPDATE source_registry SET status='Blocked_OCR',
  known_limitations='Official MEA/GCC PDFs confirmed fetchable; spec & maintenance tables are EMBEDDED IMAGES -> need OCR. /mea-public/.../gcc/ folder is the GCC target path.'
 WHERE source_reg_id='SRC-BYD-MEA';
-- Haval: no official GCC source located (third-party rejected)
UPDATE source_registry SET reliability_grade='A', status='Unavailable',
  known_limitations='No official GWM/Haval GCC owner-manual PDF located on distributor sites (greatwall.com.sa etc. empty). Only third-party hosts (rejected). Official source likely behind distributor form/login.'
 WHERE source_reg_id='SRC-GWM-HAVAL';
-- Hyundai: Tucson reachable; other models index is JS-rendered -> browser needed
UPDATE source_registry SET known_limitations='Tucson en_GN chapter reachable via fetch. OTHER models'' web-help index is JS-rendered -> chapter page-IDs need a browser (Blocked_OCR for discovery). Kia portal more fetch-friendly (doc-ids indexed).'
 WHERE source_reg_id='SRC-HYUNDAI-OM';
COMMIT;
