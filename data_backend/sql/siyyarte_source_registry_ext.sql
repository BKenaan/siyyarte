-- =====================================================================
-- Siyyarte — Source Registry EXTENSION (American, German-volume, Chinese pipelines)
-- Reliability_grade = data quality (A) ; status = extraction reachability.
-- Source quality is SEPARATE from extraction difficulty.
-- =====================================================================
BEGIN;
INSERT INTO source_registry VALUES
('SRC-GM-OWNERCENTER','Chevrolet/GMC/Cadillac','GM Owner Center PDF','https://www.chevrolet.com/ownercenter/ | https://assets.gm.com/manuals/','Owner Manual PDF (text-layer)','A','North America (US-spec)','web_fetch PDF',
 'Capacities & Specifications: engine oil capacity, coolant, fuel tank, tyre, fluids — text-layer, fetchable','US-spec only (Lebanon imports are US-spec — correct); per model/year URL pattern needed; GMC/Cadillac share CDN (confirm 1 URL each)',
 '1) Resolve model/year PDF; 2) fetch; 3) read "Capacities and Specifications"; 4) tag market=North America.','2026-06-12','Verified_A'),
('SRC-FORD-CATALOG','Ford','Ford Service Content Catalog PDF','https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/','Owner Manual PDF (text-layer)','A','North America (US-spec)','web_fetch PDF',
 'FLUID CAPACITIES, Cooling System Capacity, Fuel Tank Capacity — text-layer','Use Catalog /owner_information/*.pdf (NOT the vdirsnet HTML viewer = JS-empty); US-spec',
 'Use Catalog PDF path per model/year; extract capacities table.','2026-06-12','Verified_A'),
('SRC-MOPAR','Jeep/Dodge/RAM','Mopar vehicleinfo PDF','https://vehicleinfo.mopar.com/assets/publications/','Owner Manual PDF (text-layer)','A','North America (US-spec)','web_fetch PDF',
 'FLUID CAPACITIES section (text); engine/fluids','US-spec; Stellantis EMEA PDFs are image-only (OCR) — prefer Mopar US text PDFs','Fetch Mopar US PDF; extract capacities; tag US-spec.','2026-06-12','Verified_A'),
('SRC-OPEL-SERVICEBOX','Opel','Opel public ServiceBox PDF','https://public-servicebox.opel.com/','Owner Manual PDF (text-layer)','A','Europe','web_fetch PDF',
 'Owner manual incl. capacities — text-layer, fully open','Low Lebanese fleet (opportunistic); URL pattern brand/model/gen/year/manual_user','Use servicebox URL pattern.','2026-06-12','Verified_A'),
('SRC-BYD-MEA','BYD','BYD MEA GCC Owner Manual PDF','https://www.byd.com/content/dam/byd-site/mea-public/after-sales/manual/gcc/','Owner Manual PDF (text-layer)','A','GCC','web_fetch PDF',
 'Owner manual incl. Maintenance Cycle & Items, tyre pressure; fluid capacities in companion Warranty & Maintenance manual','Landing page JS-gated but PDFs bypass it; enumerate per model','Enumerate GCC PDFs (Atto3/Seal/Song) + companion maint manual.','2026-06-12','Verified_A'),
('SRC-GAC-SAUDI','GAC','GAC Saudi (Aljomaih) PDF','https://en.gacmotorsaudi.com/pdfs/','Owner Manual PDF (text-layer)','A','GCC (KSA)','web_fetch PDF',
 'Full owner manual; maintenance/fluids in companion Warranty & Maintenance manual','Probe /pdfs/ per model (GS3/GS8/Emkoo); locate separate maint manual for capacities','Probe /pdfs/; pull maintenance manual.','2026-06-12','Verified_A'),
('SRC-GWM-HAVAL','Haval (GWM)','GWM regional CDN PDF','https://newretailwebsite.s3.ap-southeast-1.amazonaws.com/public/PDF/OWNER-MANUAL/','Owner Manual PDF (text-layer)','A','Regional (confirm GCC variant)','web_fetch PDF',
 'Owner manual incl. Maintenance + Engine oil sections (English)','Confirm GCC/EN variant vs TH-market; cross-check capacities by region','Pull H6/Jolion EN PDFs; verify region.','2026-06-12','Verified_A'),
('SRC-MG-ME','MG','MG Motor ME portal + MG UK PDFs','https://mgmotor.me/ownership/mg-owners-manual/','Owner Manual PDF','A','GCC / UK fallback','browser (ME portal JS) ; web_fetch (UK PDF)',
 'Full owner manual (HS/ZS/5/RX5/6)','ME portal download hrefs JS-injected (browser); UK PDFs fetchable as fallback','Browser-render mgmotor.me for hrefs; else MG UK PDF.','2026-06-12','Blocked_OCR'),
('SRC-CHERY','Chery','Chery UK/Qatar download centre','https://www.cherycar.co.uk/download-center','Owner Manual PDF','A','UK/Qatar','browser (JS hrefs)',
 'Owner manuals listed (Tiggo 4/7/8) but links JS-injected','PDF hrefs not in static HTML','Browser-render download centre to extract PDF URLs.','2026-06-12','Blocked_OCR'),
('SRC-AUDI-OM','Audi','Audi online owner manual (JS SPA)','https://ownersmanual.audi.com/','Owner Manual (HTML SPA)','A','Global','browser (JS render; no PDF route)',
 'Full owner manual incl. capacities','JS SPA returns empty body on fetch; no official PDF download','Headless/browser render required.','2026-06-12','Blocked_OCR'),
('SRC-VW-OM','Volkswagen','VW digital manual / maintenance.vw.com','https://www.vw.com/en/owners-and-services/about-my-vehicle/owners-manuals.html','Owner Manual (digital)','A','US/Global','login (VIN/account)',
 'Full owner manual incl. capacities','Behind VIN entry / account','Browser + VIN, or VW ME regional portal.','2026-06-12','Blocked_Login'),
('SRC-HONDA-AE','Honda','Honda UAE owner portal','https://www.honda.ae/en/cars/owners/owners-manual/','Owner Manual','A','GCC','login-gated',
 'Owner manual incl. capacities','Login/account gated','Authenticated portal or browser.','2026-06-12','Blocked_Login'),
('SRC-LANDROVER','Land Rover','Topix owner portal','https://topix.landrover.jlrext.com/','Service info','A','Global/GCC','login-gated',
 'Service & maintenance specs','Login gated','Authenticated portal or browser.','2026-06-12','Blocked_Login'),
('SRC-CHANGAN','Changan','Changan distributor brochures','https://changanoman.com/en/download','Spec brochure PDF','C','GCC','web_fetch PDF (brochure)',
 'Engine/dimensions only (brochure); NO official owner manual found','Owner manual not located on OEM/distributor','Search KSA/global for an official OM before promoting.','2026-06-12','Unavailable'),
('SRC-JETOUR','Jetour','Jetour KSA spec flyer','https://jetourksa.com/static/pdfs/','Spec flyer PDF','C','GCC','web_fetch PDF (flyer)',
 'Engine/dimensions only; "manual" link on jetour.me is an OBDII dongle guide (DO NOT USE)','No genuine OEM owner manual located','Search jetourauto.com global/KSA distributor.','2026-06-12','Unavailable'),
('SRC-GEELY','Geely','Geely (dealer-only manual)','https://www.geely.com/','—','C','Global','none (dealer-only)',
 'Specs via brochures; owner manual dealer-only per Geely FAQ','OEM explicitly directs to dealership; no downloadable manual','Check GCC distributor; else mark secondary.','2026-06-12','Unavailable'),
('SRC-SUZUKI','Suzuki','Suzuki ME / global (not located)','https://www.globalsuzuki.com/automobile/owners_manuals/','Owner Manual','A','GCC','JS-only / not located',
 'Owner manual (capacities) — not located via fetch','globalsuzuki index JS-empty; no ME OM PDF found','Search Suzuki ME / India OM portal.','2026-06-12','Unavailable');
COMMIT;
