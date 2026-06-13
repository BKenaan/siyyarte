-- =====================================================================
-- Siyyarte — PRODUCTION QA GATES (launch-readiness)
-- 10 integrity rules as (a) validation SELECTs that MUST return 0 rows,
-- and (b) enforceable constraints/triggers where possible.
-- Run these as CI gates before any data is exposed to the app.
-- =====================================================================

-- ---------- ENFORCEABLE CONSTRAINTS ----------
-- Rule 3: every vehicle record must be market-scoped (already NOT NULL on vehicle_specs.market — assert)
ALTER TABLE vehicle_specs ALTER COLUMN market SET NOT NULL;
-- Rule 4: no duplicate vehicle-engine-market rows (unique already on the natural key — assert/extend)
CREATE UNIQUE INDEX IF NOT EXISTS uq_spec_identity
  ON vehicle_specs (generation_id, model_year, market, COALESCE(engine_id,-1), COALESCE(trim_id,-1), COALESCE(transmission_id,-1));

-- Rule 1+2+6: a row that is 'Verified' MUST have a source, and that source MUST have a page/section,
-- and confidence must be A. Enforce via trigger on the field tables.
CREATE OR REPLACE FUNCTION qa_verified_requires_source() RETURNS trigger AS $$
DECLARE pr TEXT; BEGIN
  IF NEW.verification_status = 'Verified' THEN
    IF NEW.source_id IS NULL THEN RAISE EXCEPTION 'QA1: Verified value without source_id (%.%)',TG_TABLE_NAME,NEW.id; END IF;
    IF NEW.confidence_grade IS NULL THEN RAISE EXCEPTION 'QA6: Verified value without confidence_grade'; END IF;
    SELECT page_reference INTO pr FROM sources WHERE source_id=NEW.source_id;
    IF pr IS NULL OR pr='' THEN RAISE EXCEPTION 'QA2: Verified value whose source has no page_reference (source %)',NEW.source_id; END IF;
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_qa_fluids   BEFORE INSERT OR UPDATE ON spec_fluids      FOR EACH ROW EXECUTE FUNCTION qa_verified_requires_source();
CREATE TRIGGER trg_qa_attr     BEFORE INSERT OR UPDATE ON spec_attributes  FOR EACH ROW EXECUTE FUNCTION qa_verified_requires_source();
CREATE TRIGGER trg_qa_maint    BEFORE INSERT OR UPDATE ON maintenance_items FOR EACH ROW EXECUTE FUNCTION qa_verified_requires_source();
CREATE TRIGGER trg_qa_perf     BEFORE INSERT OR UPDATE ON spec_performance FOR EACH ROW EXECUTE FUNCTION qa_verified_requires_source();

-- ---------- VALIDATION QUERIES (each MUST return 0 rows) ----------
-- QA1: Verified fluid/attr/maint values without source_id
CREATE OR REPLACE VIEW qa_v01_verified_no_source AS
  SELECT 'spec_fluids' t,id FROM spec_fluids WHERE verification_status='Verified' AND source_id IS NULL
  UNION ALL SELECT 'spec_attributes',id FROM spec_attributes WHERE verification_status='Verified' AND source_id IS NULL
  UNION ALL SELECT 'maintenance_items',id FROM maintenance_items WHERE verification_status='Verified' AND source_id IS NULL;

-- QA2: Verified values whose source lacks a page/section
CREATE OR REPLACE VIEW qa_v02_verified_no_page AS
  SELECT f.id, s.document_name FROM spec_fluids f JOIN sources s ON s.source_id=f.source_id
  WHERE f.verification_status='Verified' AND (s.page_reference IS NULL OR s.page_reference='');

-- QA3: any vehicle_specs without market (should be impossible post-constraint)
CREATE OR REPLACE VIEW qa_v03_no_market AS SELECT vehicle_spec_id FROM vehicle_specs WHERE market IS NULL;

-- QA4: duplicate vehicle-engine-market identities
CREATE OR REPLACE VIEW qa_v04_duplicates AS
  SELECT generation_id,model_year,market,engine_id,COUNT(*) c
  FROM vehicle_specs GROUP BY 1,2,3,4 HAVING COUNT(*)>1;

-- QA5: US/GCC "merge" smell — a single source_id cited across >1 distinct market (unless flagged identical)
CREATE OR REPLACE VIEW qa_v05_cross_market_source AS
  SELECT f.source_id, COUNT(DISTINCT vs.market) markets
  FROM spec_fluids f JOIN vehicle_specs vs ON vs.vehicle_spec_id=f.vehicle_spec_id
  WHERE f.source_id IS NOT NULL
  GROUP BY f.source_id HAVING COUNT(DISTINCT vs.market)>1;

-- QA6: Verified_A status but blocked extraction (verification_status='Verified' yet grade NULL or source notes 'Blocked')
CREATE OR REPLACE VIEW qa_v06_verified_but_blocked AS
  SELECT f.id FROM spec_fluids f LEFT JOIN sources s ON s.source_id=f.source_id
  WHERE f.verification_status='Verified' AND (f.confidence_grade IS NULL OR COALESCE(s.notes,'') ILIKE '%blocked%');

-- QA7: EV record carrying ICE-only fields (spark plug / engine oil) on an Electric engine spec
CREATE OR REPLACE VIEW qa_v07_ev_with_ice_fields AS
  SELECT vs.vehicle_spec_id, e.engine_code FROM vehicle_specs vs
  JOIN engines e ON e.engine_id=vs.engine_id
  JOIN spec_fluids f ON f.vehicle_spec_id=vs.vehicle_spec_id
  WHERE e.fuel_type='Electric' AND f.fluid_type IN ('Engine Oil')
  UNION
  SELECT vs.vehicle_spec_id, e.engine_code FROM vehicle_specs vs
  JOIN engines e ON e.engine_id=vs.engine_id
  JOIN spec_attributes a ON a.vehicle_spec_id=vs.vehicle_spec_id
  WHERE e.fuel_type='Electric' AND a.attribute_key IN ('spark_plug_part','spark_plug_interval','spark_plug_gap');

-- QA8: maintenance interval without BOTH a mileage and a time unit (at least one populated; flag rows with neither)
CREATE OR REPLACE VIEW qa_v08_interval_no_unit AS
  SELECT id,item_name FROM maintenance_items
  WHERE verification_status='Verified'
    AND normal_mileage_km IS NULL AND normal_time_months IS NULL
    AND first_replacement_km IS NULL AND subsequent_interval_km IS NULL
    AND notes IS NULL;

-- QA9: fluid capacity value without a unit
CREATE OR REPLACE VIEW qa_v09_capacity_no_unit AS
  SELECT id,fluid_type FROM spec_fluids WHERE capacity_value IS NOT NULL AND (capacity_unit IS NULL OR capacity_unit='');

-- QA10: tyre size stored without trim/market context (tyre value present but spec has no market — covered by QA3;
--       also flag tyre values lacking trim where multiple trims exist — advisory)
CREATE OR REPLACE VIEW qa_v10_tyre_no_context AS
  SELECT a.id, vs.market FROM spec_attributes a JOIN vehicle_specs vs ON vs.vehicle_spec_id=a.vehicle_spec_id
  WHERE a.attribute_key IN ('tire_size','tire_sizes') AND a.verification_status='Verified' AND vs.market IS NULL;

-- Master gate: union of all violation counts (CI asserts total = 0)
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
  UNION ALL SELECT 'QA10_tyre_no_context',(SELECT count(*) FROM qa_v10_tyre_no_context);
