-- Siyyarte — Source Registry refinements after Phase-4 (honest blockers + corrections)
BEGIN;
-- CORRECTION: Hyundai ownersmanual.hyundai.com is the EUROPEAN portal; GCC (en_GN) "not active".
-- Reclassify; real GCC source = national sites (hyundai.com/sa, hyundai-motor.ae) + dealer service booklet.
UPDATE source_registry SET status='Unavailable', region='Europe (NOT GCC)',
  base_url='hyundai.com/sa | hyundai-motor.ae (GCC national sites) — ownersmanual.hyundai.com is EU-only',
  known_limitations='CORRECTED: ownersmanual.hyundai.com = Hyundai EUROPE portal; GCC en_GN returns E005 "service not active". GCC capacities live in dealer Service & Warranty booklet, not the owner manual. RE-VERIFY any record earlier attributed to this portal as GCC (e.g. Tucson).'
 WHERE source_reg_id='SRC-HYUNDAI-OM';
-- BYD: GCC official PDFs CONFIRMED (paths verified); values blocked by sandbox PDF-fetch limits, not by source
UPDATE source_registry SET status='Blocked_OCR', reliability_grade='A',
  base_url='https://www.byd.com/content/dam/byd-site/mea-public/after-sales/manual/gcc/BYD_<MODEL>_<TYPE>_Owner''s_Manual.pdf',
  known_limitations='GCC PDFs CONFIRMED live (Atto3 EV, Seal EV, Sealion7 EV, Song Plus DM-i HEV). Spec/maint pages are 200-300pp deep; blocked by sandbox (web_fetch truncates ~120pp; binary-fetch neutralized). Needs allowlist or local download to extract. Source = Grade A.'
 WHERE source_reg_id='SRC-BYD-MEA';
-- MG: ME portal CDN corrected to media-hub (not scene7); lineup corrected
UPDATE source_registry SET status='Blocked_OCR', reliability_grade='A',
  base_url='https://media-hub-prod.mgmotor.me/manuals/MG_<MODEL>_English.pdf (via mgmotor.me/owners/technical-support)',
  known_limitations='ME PDFs CONFIRMED live (ZS, HS, HS Hybrid, GT, MG5, MG7, MG4, Cyberster EV...). LINEUP: RX5->RX9, MG6->MG7 (discontinued in ME). Spec pages past fetch-truncation; needs allowlist/local download. Source = Grade A.'
 WHERE source_reg_id='SRC-MG-ME';
-- NEW: GCC source discovery for American vehicles (GM/Ford full-size are largely federalized US products)
INSERT INTO source_registry VALUES
('SRC-GM-GCC','Chevrolet/GMC/Cadillac (GCC)','GM Middle East owner manual','https://www.gmarabia.com / dealer (AGMC, Al-Ghandi)','Owner Manual','A','GCC','login/dealer (no public PDF)',
 'GCC owner manuals for full-size SUVs/trucks','GM does not publish downloadable GCC owner manuals publicly; GCC trucks/SUVs share US engines (L84/L87) but octane/heat-pkg differ. DO NOT merge with US records.',
 'Confirm whether a distinct GCC owner manual exists; if only dealer-issued -> Blocked_Login. Until then GCC records = Official Source Not Found.','2026-06-12','Blocked_Login'),
('SRC-FORD-GCC','Ford (GCC)','Ford Middle East owner resources','https://me.ford.com','Owner Manual','A','GCC','browser/login (region-gated)',
 'GCC owner manuals (Explorer/F-150/Expedition/Edge)','Ford ME owner section is region/JS-gated; GCC variants share US powertrains but tuning/octane differ. DO NOT merge with US records.',
 'Probe me.ford.com for GCC PDFs; if none public -> Official Source Not Found / Blocked_Login.','2026-06-12','Blocked_Login');
COMMIT;
