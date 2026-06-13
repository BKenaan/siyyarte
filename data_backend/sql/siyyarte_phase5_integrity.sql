-- =====================================================================
-- Siyyarte — Phase 5: source reverification + integrity hardening
-- =====================================================================
BEGIN;

-- ---------- QA findings log (Priority 1.3 + Deliverable 11) ----------
CREATE TABLE qa_findings (
    finding_id       BIGSERIAL PRIMARY KEY,
    raised_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    affected_vehicle TEXT NOT NULL,
    affected_fields  TEXT NOT NULL,
    original_source  TEXT,
    suspected_issue  TEXT NOT NULL,
    required_fix     TEXT,
    severity         TEXT CHECK (severity IN ('LOW','MEDIUM','HIGH')),
    current_status   TEXT CHECK (current_status IN ('OPEN','IN_PROGRESS','RESOLVED','WONTFIX')) DEFAULT 'OPEN'
);

INSERT INTO qa_findings (affected_vehicle,affected_fields,original_source,suspected_issue,required_fix,severity,current_status) VALUES
('Hyundai Tucson NX4 (GCC record)','ALL fluid/attribute values (oil, coolant, ATF, brake, fuel tank, diff)',
 'ownersmanual.hyundai.com en_GN (assumed GCC)',
 'Portal confirmed to be Hyundai EUROPE; en_GN GCC service "not active". Values may be EU-spec mislabelled as GCC.',
 'Re-source from Hyundai GCC national sites (hyundai.com/sa, hyundai-motor.ae) or dealer Service & Warranty booklet; only restore Verified once GCC provenance confirmed.',
 'HIGH','IN_PROGRESS'),
('Hyundai/Kia (all records via ownersmanual.* portals)','market label vs source region',
 'ownersmanual.hyundai.com / ownersmanual.kia.com',
 'Hyundai portal = EU. Kia portal had explicit "Middle East" rows (lower risk) but must be re-confirmed.',
 'Audit every Hyundai/Kia record; confirm the cited document explicitly covers GCC/ME.',
 'MEDIUM','IN_PROGRESS');

-- ---------- Tucson downgrade: prevent Verified_A render, KEEP data (Priority 1.1/1.2) ----------
-- Set verification_status='Not Verified' (=> API will not render as final) for the GCC Tucson spec(s).
UPDATE spec_fluids SET verification_status='Not Verified'
 WHERE vehicle_spec_id IN (
   SELECT vs.vehicle_spec_id FROM vehicle_specs vs
   JOIN generations g ON g.generation_id=vs.generation_id
   WHERE g.code='NX4' AND vs.market='GCC');
UPDATE spec_attributes SET verification_status='Not Verified'
 WHERE vehicle_spec_id IN (
   SELECT vs.vehicle_spec_id FROM vehicle_specs vs
   JOIN generations g ON g.generation_id=vs.generation_id
   WHERE g.code='NX4' AND vs.market='GCC');
-- (values remain in columns for re-verification; just not surfaced as Verified)

-- ---------- Local official-source archive (Priority 2 + Deliverable 3/4) ----------
CREATE TABLE source_archive (
    archive_id       BIGSERIAL PRIMARY KEY,
    original_url     TEXT NOT NULL,
    oem              TEXT,
    brand            TEXT,
    model            TEXT,
    market           market_region,
    model_year       INT,
    document_title   TEXT,
    document_type    TEXT,            -- Owner Manual / Warranty & Maintenance / Spec Sheet / Service Booklet
    date_accessed    DATE,
    local_file_path  TEXT,            -- /raw_sources/{brand}/{market}/{year}/{model}/{doc}.pdf
    sha256_hash      CHAR(64),        -- file integrity / drift detection
    page_count       INT,
    extraction_method TEXT,           -- web_fetch / local pdftotext / browser pdf.js / OCR
    source_status    verification_level,
    UNIQUE (sha256_hash)
);
COMMENT ON TABLE source_archive IS 'Preserves official PDFs against OEM source drift. sources.source_id should reference an archive_id once a doc is archived.';
-- link sources -> archive (nullable until archived)
ALTER TABLE sources ADD COLUMN IF NOT EXISTS archive_id BIGINT REFERENCES source_archive(archive_id);
-- enforce: a Verified value whose source uses a LOCAL file must have a hash
-- (validation view; CI asserts 0)
CREATE OR REPLACE VIEW qa_v11_local_source_no_hash AS
  SELECT s.source_id, s.document_name FROM sources s
  JOIN source_archive a ON a.archive_id=s.archive_id
  WHERE a.local_file_path IS NOT NULL AND (a.sha256_hash IS NULL OR a.sha256_hash='');

-- ---------- QA rule: no Hyundai-Europe source backing a GCC value (Priority 7) ----------
CREATE OR REPLACE VIEW qa_v12_eu_source_gcc_value AS
  SELECT f.id, s.document_name, vs.market FROM spec_fluids f
  JOIN vehicle_specs vs ON vs.vehicle_spec_id=f.vehicle_spec_id
  JOIN sources s ON s.source_id=f.source_id
  WHERE f.verification_status='Verified' AND vs.market='GCC'
    AND (s.url ILIKE '%ownersmanual.hyundai.com%' OR s.notes ILIKE '%europe%');

-- extend master gate
CREATE OR REPLACE VIEW qa_master_gate AS
  SELECT 'QA1_verified_no_source' rule,(SELECT count(*) FROM qa_v01_verified_no_source) n
  UNION ALL SELECT 'QA2_verified_no_page',(SELECT count(*) FROM qa_v02_verified_no_page)
  UNION ALL SELECT 'QA3_no_market',(SELECT count(*) FROM qa_v03_no_market)
  UNION ALL SELECT 'QA4_duplicates',(SELECT count(*) FROM qa_v04_duplicates)
  UNION ALL SELECT 'QA5_cross_market_source',(SELECT count(*) FROM qa_v05_cross_market_source)
  UNION ALL SELECT 'QA6_verified_but_blocked',(SELECT count(*) FROM qa_v06_verified_but_blocked)
  UNION ALL SELECT 'QA7_ev_with_ice_fields',(SELECT count(*) FROM qa_v07_ev_with_ice_fields)
  UNION ALL SELECT 'QA8_interval_no_unit',(SELECT count(*) FROM qa_v08_interval_no_unit)
  UNION ALL SELECT 'QA9_capacity_no_unit',(SELECT count(*) FROM qa_v09_capacity_no_unit)
  UNION ALL SELECT 'QA10_tyre_no_context',(SELECT count(*) FROM qa_v10_tyre_no_context)
  UNION ALL SELECT 'QA11_local_source_no_hash',(SELECT count(*) FROM qa_v11_local_source_no_hash)
  UNION ALL SELECT 'QA12_eu_source_gcc_value',(SELECT count(*) FROM qa_v12_eu_source_gcc_value);

COMMIT;
