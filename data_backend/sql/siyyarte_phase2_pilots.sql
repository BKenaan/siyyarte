-- =====================================================================
-- Siyyarte — Phase 2/3 extraction batch (Grade A, field-level cited)
-- ACCEPTANCE-GATE PILOTS: Chevrolet Tahoe, GMC Yukon, Ford Explorer, Ford F-150
--   ALL market='North America' (US-spec). Do NOT merge with GCC.
-- Plus Kia Sportage/Cerato/Sorento (GCC), GAC Emzoom/Emkoo intervals (GCC).
-- Integrity: official-only; not-in-manual = NULL/Not Verified; no secondary.
-- =====================================================================
BEGIN;

INSERT INTO makes (name) VALUES ('Chevrolet'),('GMC'),('Ford'),('GAC') ON CONFLICT DO NOTHING;
INSERT INTO models (make_id,name) VALUES
 ((SELECT make_id FROM makes WHERE name='Chevrolet'),'Tahoe'),
 ((SELECT make_id FROM makes WHERE name='GMC'),'Yukon'),
 ((SELECT make_id FROM makes WHERE name='Ford'),'Explorer'),
 ((SELECT make_id FROM makes WHERE name='Ford'),'F-150'),
 ((SELECT make_id FROM makes WHERE name='Kia'),'Sportage'),
 ((SELECT make_id FROM makes WHERE name='Kia'),'Cerato / Forte'),
 ((SELECT make_id FROM makes WHERE name='Kia'),'Sorento'),
 ((SELECT make_id FROM makes WHERE name='GAC'),'GS3 Emzoom'),
 ((SELECT make_id FROM makes WHERE name='GAC'),'Emkoo')
ON CONFLICT DO NOTHING;
INSERT INTO generations (model_id,code,name,year_start,year_end) VALUES
 ((SELECT model_id FROM models WHERE name='Tahoe'),'T1XX','5th gen',2021,2026),
 ((SELECT model_id FROM models WHERE name='Yukon'),'T1XX','5th gen',2021,2026),
 ((SELECT model_id FROM models WHERE name='Explorer'),'U625','6th gen',2020,2026),
 ((SELECT model_id FROM models WHERE name='F-150'),'P702','14th gen',2021,2026),
 ((SELECT model_id FROM models WHERE name='Sportage'),'NQ5','5th gen',2022,2026),
 ((SELECT model_id FROM models WHERE name='Cerato / Forte'),'BD','4th gen',2018,2026),
 ((SELECT model_id FROM models WHERE name='Sorento'),'MQ4','4th gen',2020,2026),
 ((SELECT model_id FROM models WHERE name='GS3 Emzoom'),'GS3','1st gen',2022,2026),
 ((SELECT model_id FROM models WHERE name='Emkoo'),'Emkoo','1st gen',2022,2026);
INSERT INTO engines (engine_code,engine_name,displacement_cc,displacement_l,fuel_type,aspiration,cylinders) VALUES
 ('L84','5.3L V8',5300,5.3,'Petrol','Naturally aspirated',8),
 ('L87','6.2L V8',6200,6.2,'Petrol','Naturally aspirated',8),
 ('Ford2.3EB','2.3L EcoBoost I4',2261,2.3,'Petrol','Turbocharged',4),
 ('Ford3.0EB','3.0L EcoBoost V6',2956,3.0,'Petrol','Twin-turbocharged',6),
 ('Ford2.7EB','2.7L EcoBoost V6',2700,2.7,'Petrol','Twin-turbocharged',6),
 ('Ford3.5EB','3.5L EcoBoost V6',3497,3.5,'Petrol','Twin-turbocharged',6),
 ('Ford5.0','5.0L V8 Coyote',5038,5.0,'Petrol','Naturally aspirated',8)
ON CONFLICT DO NOTHING;

INSERT INTO sources (document_name,url,publisher,source_tier,confidence_grade,page_reference,access_date,notes) VALUES
('2023 Chevrolet Tahoe/Suburban Owner Manual (US)','https://contentdelivery.ext.gm.com/.../23_CHEV_Tahoe_Suburban_OM_en_US_84979315B.pdf','General Motors','1','A','Capacities & Specs p.408; Maint p.401; Fuel p.285','2026-06-12','US-spec; in-browser pdf.js parse'),
('2023 GMC Yukon Owner Manual (US)','https://contentdelivery.ext.gm.com/.../23_GMC_Yukon_OM_en_US_16417394C.pdf','General Motors','1','A','Capacities & Specs p.407; Maint p.398','2026-06-12','US-spec'),
('2022 Ford Explorer Owner Manual (US)','https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2022-Ford-Explorer-Owners-Manual-version-1_om_EN-US_09_2021.pdf','Ford Motor Co','1','A','Capacities p.382-413; Maint p.479-482','2026-06-12','US-spec; 567pp; in-browser pdf.js'),
('2022 Ford F-150 Owner Manual (US)','https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2022-Ford-F-150-Owners-Manual-version-1_om_EN-US_10_2021.pdf','Ford Motor Co','1','A','Capacities p.562-587; Maint p.646-652','2026-06-12','US-spec; 750pp'),
('Kia Sportage NQ5 Owner Manual (Middle East)','https://ownersmanual.kia.com/docview/webhelp/doc/52640c78-ea53-42f4-92e6-79be09064664/topics/chapter9_7.html','Kia Corp','1','A','chapter9_7 Recommended lubricants & capacities','2026-06-12','For Middle East rows'),
('Kia Cerato/Forte BD Owner Manual (Middle East)','https://ownersmanual.kia.com/docview/webhelp/doc/6ea23c34-4fc1-413d-8272-3c1499b4c295/topics/chapter9_8.html','Kia Corp','1','A','chapter9_8','2026-06-12','For Middle East rows'),
('Kia Sorento MQ4 Owner Manual','https://ownersmanual.kia.com/docview/webhelp/doc/b3e507da-dfcc-457e-8279-5bbfb8e9960f/topics/chapter9_8.html','Kia Corp','1','A','chapter9_8','2026-06-12','Single global spec'),
('GAC GS3 Emzoom Warranty & Maintenance Manual (KSA)','https://en.gacmotorsaudi.com/pdfs/emzoom-owner''s-warranty-EN.pdf','GAC Motor','1','A','Sec 3.2 Regular maintenance p.10-14','2026-06-12','Intervals only; capacities are image tables (Blocked_OCR)'),
('GAC Emkoo Warranty & Maintenance Manual (KSA)','https://en.gacmotorsaudi.com/pdfs/emkoo-owner''s-warranty-EN.pdf','GAC Motor','1','A','Sec 3.2 p.10-13','2026-06-12','Intervals only; capacities Blocked_OCR');

-- ===== GM PILOTS: Tahoe + Yukon (US-spec, shared L84/L87) =====
DO $$
DECLARE
  s_t BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE '2023 Chevrolet Tahoe%');
  s_y BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE '2023 GMC Yukon%');
  e53 INT:=(SELECT engine_id FROM engines WHERE engine_code='L84');
  e62 INT:=(SELECT engine_id FROM engines WHERE engine_code='L87');
  rec RECORD; sp BIGINT;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    ('Tahoe','T1XX',s_t,e53,'5.3L V8',14.8,'87'),
    ('Tahoe','T1XX',s_t,e62,'6.2L V8',14.3,'91'),
    ('Yukon','T1XX',s_y,e53,'5.3L V8',14.8,'87'),
    ('Yukon','T1XX',s_y,e62,'6.2L V8',14.3,'91')
  ) AS t(model,gcode,src,eid,ename,coolant,octane) LOOP
    INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain)
      VALUES ((SELECT g.generation_id FROM generations g JOIN models m ON m.model_id=g.model_id WHERE m.name=rec.model AND g.code=rec.gcode),
              2023,'North America',rec.eid,'4WD') RETURNING vehicle_spec_id INTO sp;
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil','dexos1 full synthetic, SAE 0W-20',7.6,'L (8.0 qt, with filter)',rec.src,'A','Verified','2026-06-12'),
     (sp,'Coolant','GM coolant',rec.coolant,'L',rec.src,'A','Verified','2026-06-12'),
     (sp,'Transmission','DEXRON ULV ATF',NULL,'L (capacity not listed in manual)',rec.src,'A','Verified','2026-06-12'),
     (sp,'Brake',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL);
    INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'fuel_tank_l','90.8 L (24 gal SWB) / 106 L (28 gal LWB)',rec.src,'A','Verified','2026-06-12'),
     (sp,'fuel_requirement',CASE WHEN rec.octane='87' THEN 'Regular unleaded, min 87 AKI' ELSE 'Premium 91 AKI recommended (87 permitted, reduced performance)' END,rec.src,'A','Verified','2026-06-12'),
     (sp,'spark_plug_gap','0.95-1.10 mm (0.037-0.043 in)',rec.src,'A','Verified','2026-06-12'),
     (sp,'tire_size',NULL,NULL,NULL,'Not Verified',NULL);
    INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,normal_time_months,notes,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil & Filter',NULL,12,'GM Oil Life System (algorithmic); min once per year',rec.src,'A','Verified','2026-06-12'),
     (sp,'Cabin Air Filter',36000,24,NULL,rec.src,'A','Verified','2026-06-12'),
     (sp,'Engine Coolant',240000,72,'150,000 mi / 6 yr',rec.src,'A','Verified','2026-06-12'),
     (sp,'Spark Plugs',156000,NULL,'97,500 mi',rec.src,'A','Verified','2026-06-12');
    INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,source_id,confidence_grade,verification_status) VALUES
     (sp,TRUE,'North America','US-spec used import (common in Lebanon). Diesel 3.0 Duramax = separate supplement (NULL).',rec.src,'A','Verified');
  END LOOP;
END $$;

-- ===== FORD PILOTS: Explorer + F-150 (US-spec, per engine) =====
DO $$
DECLARE
  s_e BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE '2022 Ford Explorer%');
  s_f BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE '2022 Ford F-150%');
  rec RECORD; sp BIGINT;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    ('Explorer','U625',s_e,'Ford2.3EB',4.9,'SAE 5W-30 Synthetic Blend (WSS-M2C961-A1)',13.3,'67.8','160000'),
    ('Explorer','U625',s_e,'Ford3.0EB',5.7,'SAE 5W-30 Synthetic Blend (WSS-M2C961-A1)',14.7,'76.5','160000'),
    ('F-150','P702',s_f,'Ford2.7EB',5.7,'SAE 5W-30 Synthetic Blend (WSS-M2C961-A1)',14.3,'87.1','96600'),
    ('F-150','P702',s_f,'Ford3.5EB',5.7,'SAE 5W-30 Synthetic Blend (WSS-M2C961-A1)',13.5,'87.1','96600'),
    ('F-150','P702',s_f,'Ford5.0',7.33,'SAE 5W-30 Synthetic Blend (WSS-M2C961-A1)',12.5,'87.1','96600')
  ) AS t(model,gcode,src,ecode,oil,oilspec,coolant,tank,spark) LOOP
    INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain)
      VALUES ((SELECT g.generation_id FROM generations g JOIN models m ON m.model_id=g.model_id WHERE m.name=rec.model AND g.code=rec.gcode),
              2022,'North America',(SELECT engine_id FROM engines WHERE engine_code=rec.ecode),(CASE WHEN rec.model='Explorer' THEN 'AWD' ELSE '4WD' END)::drivetrain_type)
      RETURNING vehicle_spec_id INTO sp;
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil',rec.oilspec,rec.oil,'L (with filter)',rec.src,'A','Verified','2026-06-12'),
     (sp,'Coolant','Motorcraft Yellow Prediluted (WSS-M97B57-A2)',rec.coolant,'L',rec.src,'A','Verified','2026-06-12'),
     (sp,'Transmission',CASE WHEN rec.model='Explorer' THEN 'Motorcraft MERCON ULV (WSS-M2C949-A)' ELSE 'Motorcraft MERCON LV (WSS-M2C938-A)' END,NULL,'L (fill qty not listed)',rec.src,'A','Verified','2026-06-12'),
     (sp,'Brake','Motorcraft DOT 4 LV High Performance (PM-20)',NULL,NULL,rec.src,'A','Verified','2026-06-12');
    INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'fuel_tank_l',rec.tank||' L',rec.src,'A','Verified','2026-06-12'),
     (sp,'fuel_requirement','Regular unleaded min 87 AKI; premium 91+ recommended for best performance',rec.src,'A','Verified','2026-06-12'),
     (sp,'tire_size',NULL,NULL,NULL,'Not Verified',NULL);
    INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,normal_time_months,notes,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil & Filter',16000,12,'Intelligent Oil-Life Monitor up to 1yr/10,000 mi',rec.src,'A','Verified','2026-06-12'),
     (sp,'Cabin Air Filter',32000,NULL,'20,000 mi',rec.src,'A','Verified','2026-06-12'),
     (sp,'Engine Air Filter',48000,NULL,'30,000 mi',rec.src,'A','Verified','2026-06-12'),
     (sp,'Spark Plugs',rec.spark::int,NULL,'Explorer 100k mi / F-150 60k mi',rec.src,'A','Verified','2026-06-12'),
     (sp,'Engine Coolant',NULL,NULL,'First 200,000 mi (322,000 km)',rec.src,'A','Verified','2026-06-12'),
     (sp,'Transmission Fluid',240000,NULL,'150,000 mi',rec.src,'A','Verified','2026-06-12'),
     (sp,'Brake Fluid',NULL,36,'Every 3 years',rec.src,'A','Verified','2026-06-12');
    INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,source_id,confidence_grade,verification_status) VALUES
     (sp,TRUE,'North America','US-spec used import. Tyre size on door placard (NULL). 3.0 PowerStroke diesel not offered 2022 (NULL).',rec.src,'A','Verified');
  END LOOP;
END $$;

-- ===== KOREAN EXPANSION (GCC): Sportage / Cerato / Sorento =====
DO $$
DECLARE
  rec RECORD; sp BIGINT;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    ('Sportage','NQ5','Kia Sportage NQ5%','2.0 MPI',3.6,'SAE 5W-30 ACEA A5/B5 (Middle East)',5.5,'ATF SP-IV',6.7,'SAE J1703 DOT-3/DOT-4','54'),
    ('Cerato / Forte','BD','Kia Cerato%','Nu 2.0 MPI',4.0,'SAE 0W-30 API SN/ACEA C2 or 5W-30 (Middle East)',7.2,'ATF SP-IV',6.7,'DOT 4','60'),
    ('Sorento','MQ4','Kia Sorento%','G2.5 GDi',5.8,'SAE 0W-20 API SN PLUS/SP',9.1,'ATF SP4M-1',6.5,'SAE J1704 DOT-4 LV','56')
  ) AS t(model,gcode,srclike,eng,oil,oilspec,coolant,atf,atfcap,brake,tank) LOOP
    INSERT INTO vehicle_specs (generation_id,model_year,market,drivetrain)
      VALUES ((SELECT g.generation_id FROM generations g JOIN models m ON m.model_id=g.model_id WHERE m.name=rec.model AND g.code=rec.gcode),2024,'GCC','FWD')
      RETURNING vehicle_spec_id INTO sp;
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil',rec.oilspec,rec.oil,'L',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12'),
     (sp,'Coolant','Phosphate ethylene-glycol',rec.coolant,'L',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12'),
     (sp,'Transmission',rec.atf,rec.atfcap,'L',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12'),
     (sp,'Brake',rec.brake,NULL,NULL,(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12');
    INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,value_numeric,unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'fuel_tank_l',NULL,rec.tank::numeric,'L',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12'),
     (sp,'spark_plug_interval',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL);
  END LOOP;
END $$;

-- ===== GAC (GCC): Emzoom + Emkoo — maintenance intervals (capacities = Blocked_OCR) =====
DO $$
DECLARE
  rec RECORD; sp BIGINT;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    ('GS3 Emzoom','GS3','GAC GS3 Emzoom%'),
    ('Emkoo','Emkoo','GAC Emkoo%')
  ) AS t(model,gcode,srclike) LOOP
    INSERT INTO vehicle_specs (generation_id,model_year,market,drivetrain)
      VALUES ((SELECT g.generation_id FROM generations g JOIN models m ON m.model_id=g.model_id WHERE m.name=rec.model AND g.code=rec.gcode),2024,'GCC','FWD')
      RETURNING vehicle_spec_id INTO sp;
    INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,normal_time_months,first_replacement_km,severe_mileage_km,notes,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil & Filter',10000,6,5000,2500,'First 5,000 km/3mo; harsh 2,500 km',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12'),
     (sp,'Engine Coolant',40000,24,NULL,NULL,'Incl. intercooler coolant',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12'),
     (sp,'Brake Fluid',40000,24,NULL,NULL,NULL,(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12'),
     (sp,'Spark Plugs',60000,NULL,NULL,NULL,NULL,(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12'),
     (sp,'Transmission Fluid (WDCT)',60000,36,50000,NULL,'First 50,000 km/36mo',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified','2026-06-12');
    -- capacities/fuel/tyre are image tables in owner manual -> Blocked_OCR (NULL)
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,verification_status) VALUES (sp,'Engine Oil','Not Verified'),(sp,'Coolant','Not Verified');
    INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,verification_status) VALUES
     (sp,'fuel_tank_l',NULL,'Not Verified'),(sp,'capacities_status','Blocked_OCR: owner-manual spec tables are images; intervals from warranty manual (Grade A)','Not Verified');
    INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,source_id,confidence_grade,verification_status) VALUES
     (sp,TRUE,'GCC','Chinese riser; intervals Grade-A; capacities pending OCR',(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike),'A','Verified');
  END LOOP;
END $$;

COMMIT;
