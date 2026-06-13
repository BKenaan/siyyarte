-- =====================================================================
-- Siyyarte — Phase 5 reconciliation: Hyundai GCC re-verification
-- FINDING RESOLVED: ownersmanual.hyundai.com /full_webhelp/{CODE}/{YEAR}/en_GN/
--   IS the official "Gulf Nations" (GCC) locale. PROOF: it prescribes
--   Middle-East-specific oil grade (5W-30 ACEA A5/B5 "For Middle East"),
--   which an EU document does not carry. The /main SPA flow (geo-gated to EU)
--   caused the earlier false-negative. Tucson is VINDICATED.
-- Adds GCC Grade-A: Elantra (CN7), Santa Fe (MX5), Sonata (DN8).
-- =====================================================================
BEGIN;

-- Refine QA12: en_GN paths ARE GCC-valid; only flag non-en_GN Hyundai or EU-noted sources
CREATE OR REPLACE VIEW qa_v12_eu_source_gcc_value AS
  SELECT f.id, s.document_name, vs.market FROM spec_fluids f
  JOIN vehicle_specs vs ON vs.vehicle_spec_id=f.vehicle_spec_id
  JOIN sources s ON s.source_id=f.source_id
  WHERE f.verification_status='Verified' AND vs.market='GCC'
    AND ( (s.url ILIKE '%ownersmanual.hyundai.com%' AND s.url NOT ILIKE '%en_GN%')
          OR s.notes ILIKE '%europe%' );

-- Resolve the Tucson finding
UPDATE qa_findings SET current_status='RESOLVED',
  required_fix='RESOLVED: en_GN = official Gulf Nations (GCC) locale, confirmed by Middle-East-specific oil grade. Tucson values re-verified from GCC source. Confusion was the geo-gated /main SPA (EU); the /full_webhelp en_GN tree is GCC.'
 WHERE affected_vehicle LIKE 'Hyundai Tucson%';
UPDATE qa_findings SET current_status='RESOLVED',
  required_fix='RESOLVED for larger models (Tucson/Elantra/Santa Fe/Sonata = GCC Verified via en_GN). Accent/Creta/i10 = GCC source located but capacity blocked (image/brochure). i20 = not in GCC lineup.'
 WHERE affected_vehicle LIKE 'Hyundai/Kia%';

-- Restore Tucson GCC values to Verified (provenance now confirmed)
UPDATE spec_fluids SET verification_status='Verified', verification_date='2026-06-13'
 WHERE vehicle_spec_id IN (SELECT vs.vehicle_spec_id FROM vehicle_specs vs JOIN generations g ON g.generation_id=vs.generation_id WHERE g.code='NX4' AND vs.market='GCC')
   AND confidence_grade='A';
UPDATE spec_attributes SET verification_status='Verified', verification_date='2026-06-13'
 WHERE vehicle_spec_id IN (SELECT vs.vehicle_spec_id FROM vehicle_specs vs JOIN generations g ON g.generation_id=vs.generation_id WHERE g.code='NX4' AND vs.market='GCC')
   AND confidence_grade='A';

-- New Hyundai GCC sources (en_GN = Gulf Nations)
INSERT INTO sources (document_name,url,publisher,source_tier,confidence_grade,page_reference,access_date,notes) VALUES
('Hyundai Elantra CN7 Owner Manual (GCC en_GN)','https://ownersmanual.hyundai.com/full_webhelp/CN7/2024/en_GN/id8a19b15b80e.html','Hyundai Motor Co','1','A','Recommended lubricants & capacities','2026-06-13','en_GN = Gulf Nations; carries "For Middle East" oil grade'),
('Hyundai Santa Fe MX5 Owner Manual (GCC en_GN)','https://ownersmanual.hyundai.com/full_webhelp/MX5/2024/en_GN/ideebd8cfc412.html','Hyundai Motor Co','1','A','Recommended lubricants & capacities','2026-06-13','en_GN Gulf Nations; ME-specific oil grade'),
('Hyundai Sonata DN8 Owner Manual (GCC en_GN)','https://ownersmanual.hyundai.com/full_webhelp/DN8/2024/en_GN/ideebd8cfc412.html','Hyundai Motor Co','1','A','Recommended lubricants & capacities','2026-06-13','en_GN Gulf Nations; ME-specific oil grade');

INSERT INTO makes (name) VALUES ('Hyundai') ON CONFLICT DO NOTHING;
INSERT INTO models (make_id,name) VALUES
 ((SELECT make_id FROM makes WHERE name='Hyundai'),'Elantra'),
 ((SELECT make_id FROM makes WHERE name='Hyundai'),'Santa Fe'),
 ((SELECT make_id FROM makes WHERE name='Hyundai'),'Sonata')
ON CONFLICT DO NOTHING;
INSERT INTO generations (model_id,code,name,year_start,year_end) VALUES
 ((SELECT model_id FROM models WHERE name='Elantra'),'CN7','7th gen',2020,2026),
 ((SELECT model_id FROM models WHERE name='Santa Fe'),'MX5','5th gen',2023,2026),
 ((SELECT model_id FROM models WHERE name='Sonata'),'DN8','8th gen',2019,2026);

DO $$
DECLARE rec RECORD; sp BIGINT;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    ('Elantra','CN7','Hyundai Elantra%','G2.0',4.3,'5W-30 ACEA A5/B5 or 0W-30 (For Middle East)',7.4,'IVT/ATF SP4M-1',6.5,'DOT-4',47),
    ('Santa Fe','MX5','Hyundai Santa Fe%','G2.5 GDi',5.8,'5W-30 ACEA A5/B5 (For Middle East)',9.13,'ATF SP4M-1',6.5,'DOT-4 LV',67),
    ('Sonata','DN8','Hyundai Sonata%','G2.5 GDi',5.8,'5W-30 ACEA A5/B5 (For Middle East)',8.7,'ATF SP4M-1',6.5,'DOT-4',60)
  ) AS t(model,gcode,srclike,eng,oil,oilspec,coolant,atf,atfcap,brake,tank) LOOP
    INSERT INTO vehicle_specs (generation_id,model_year,market,drivetrain)
      VALUES ((SELECT g.generation_id FROM generations g JOIN models m ON m.model_id=g.model_id WHERE m.name=rec.model AND g.code=rec.gcode),2024,'GCC','FWD')
      RETURNING vehicle_spec_id INTO sp;
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil',rec.oilspec,rec.oil,'L',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-13'),
     (sp,'Coolant','Phosphate ethylene-glycol',rec.coolant,'L',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-13'),
     (sp,'Transmission',rec.atf,rec.atfcap,'L',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-13'),
     (sp,'Brake',rec.brake,NULL,NULL,(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-13');
    INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,value_numeric,unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'fuel_tank_l',NULL,rec.tank::numeric,'L',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-13'),
     (sp,'spark_plug_interval',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL);
    IF rec.model='Santa Fe' THEN
      INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date)
      VALUES (sp,'differential_oil','Rear (4WD) 0.53-0.63 L; 75W/85 GL-5',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-13');
    END IF;
    INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,source_id,confidence_grade,verification_status)
     VALUES (sp,TRUE,'GCC','en_GN Gulf Nations source; ME-specific oil grade confirms GCC provenance',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified');
  END LOOP;
END $$;

COMMIT;
