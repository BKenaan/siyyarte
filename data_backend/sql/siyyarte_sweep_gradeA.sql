-- =====================================================================
-- Siyyarte — Batch sweep Grade-A additions (fetchable official sources)
-- Methodology breakthroughs (fetchable official, no JS gate):
--   ownersmanual.hyundai.com / ownersmanual.kia.com (full fluid capacities),
--   owners-manual.mazda.com (EC market), toyota.com.sa / lexus.com.sa,
--   nissan-cdn ME catalogues, renault.qa, Mitsubishi Al-Habtoor PDFs.
-- Adds app-ready Grade-A vehicles. Integrity preserved (A-grade cited).
-- =====================================================================
BEGIN;
INSERT INTO makes (name) VALUES ('Mazda'),('Isuzu'),('Hyundai'),('Kia'),('Nissan') ON CONFLICT DO NOTHING;
INSERT INTO models (make_id,name) VALUES
 ((SELECT make_id FROM makes WHERE name='Mazda'),'CX-5'),
 ((SELECT make_id FROM makes WHERE name='Isuzu'),'D-Max'),
 ((SELECT make_id FROM makes WHERE name='Hyundai'),'Tucson'),
 ((SELECT make_id FROM makes WHERE name='Kia'),'Picanto'),
 ((SELECT make_id FROM makes WHERE name='Nissan'),'Patrol')
ON CONFLICT DO NOTHING;
INSERT INTO generations (model_id,code,name,year_start,year_end) VALUES
 ((SELECT model_id FROM models WHERE name='CX-5'),'KF','2nd gen',2017,2026),
 ((SELECT model_id FROM models WHERE name='D-Max'),'RG','3rd gen',2020,2026),
 ((SELECT model_id FROM models WHERE name='Tucson'),'NX4','4th gen',2021,2026),
 ((SELECT model_id FROM models WHERE name='Picanto'),'JA','3rd gen',2017,2026),
 ((SELECT model_id FROM models WHERE name='Patrol'),'Y63','7th gen',2024,2026);

INSERT INTO sources (document_name,url,publisher,source_tier,confidence_grade,page_reference,access_date,notes) VALUES
('Mazda CX-5 Owner''s Manual (EC: Except Europe)','https://owners-manual.mazda.com/gen/en/cx-5/cx-5_8ft1ee17b/','Mazda Motor Corp','1','A','Capacities 10020104 / Maint 07020102 / Fuel 04040101','2026-06-12','Official online manual; Lebanon explicitly named (95 RON)'),
('Isuzu D-Max Spec Sheet 24MY + service schedule','https://admin.i-motor.com.au/','Isuzu','1','A','Spec sheet','2026-06-12','RG 4JJ3-TCX; same engine GCC/Lebanon'),
('Hyundai Tucson NX4 Owner''s Manual (GCC en_GN)','https://ownersmanual.hyundai.com/full_webhelp/NX4/2025/en_GN/idcd4ca75644f.html','Hyundai Motor Co','1','A','Recommended lubricants & capacities','2026-06-12','GCC-spec webhelp manual, fetchable'),
('Kia Picanto JA Owner''s Manual (Middle East)','https://ownersmanual.kia.com/docview/webhelp/doc/d4139f11-a790-4421-9f92-40bfb353f343/topics/chapter9_7.html','Kia Corp','1','A','Recommended lubricants & capacities','2026-06-12','Explicit For Middle East rows'),
('Nissan Patrol Y63 ME Catalogue','https://www-europe.nissan-cdn.net/content/dam/Nissan/nissan_middle_east/brochures/LIB/NISSAN-ALL-NEW-PATROL-UAE-CATALOGUE.pdf','Nissan Middle East','1','A','Technical Specs pp.104-105','2026-06-12','Y63 current GCC');

-- Mazda CX-5 (complete Grade A)
DO $$
DECLARE g INT:=(SELECT generation_id FROM generations WHERE code='KF');
  s BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Mazda CX-5%'); sp BIGINT;
BEGIN
  INSERT INTO vehicle_specs (generation_id,model_year,market,drivetrain) VALUES (g,2024,'GCC','AWD') RETURNING vehicle_spec_id INTO sp;
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'Engine Oil','SAE 0W-20 (G2.0 4.2 L / G2.5 4.5 L with filter)',4.2,'L (G2.0; G2.5=4.5)',s,'A','Verified','2026-06-12'),
   (sp,'Coolant','Mazda FL-22',7.2,'L (G2.0 7.1-7.2 / G2.5 7.2-7.4)',s,'A','Verified','2026-06-12'),
   (sp,'Transmission','Mazda ATF (auto transaxle)',7.8,'L',s,'A','Verified','2026-06-12'),
   (sp,'Brake','Replace every 24 months / 40,000 km',NULL,NULL,s,'A','Verified','2026-06-12');
  INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'timing_type','Timing chain (SKYACTIV-G; no scheduled belt)',s,'A','Verified','2026-06-12'),
   (sp,'fuel_tank_l','56 L (2WD) / 58 L (4WD)',s,'A','Verified','2026-06-12'),
   (sp,'tire_size','225/65R17 102V; 225/55R19 99V; nut torque 108-147 N·m',s,'A','Verified','2026-06-12'),
   (sp,'spark_plug_interval','120,000 km (inspect from 10k km in UAE/Bahrain/Oman/Jordan/Syria)',s,'A','Verified','2026-06-12');
  INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,normal_time_months,notes,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'Engine Oil & Filter',10000,6,'Severe-use clauses listed',s,'A','Verified','2026-06-12'),
   (sp,'Engine Air Filter',60000,NULL,NULL,s,'A','Verified','2026-06-12');
  INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,recommended_octane,source_id,confidence_grade,verification_status) VALUES
   (sp,TRUE,'GCC','95 RON premium (Lebanon explicitly named in manual)',s,'A','Verified');
END $$;

-- Isuzu D-Max (near-complete Grade A; diesel pickup allowed in Lebanon)
DO $$
DECLARE g INT:=(SELECT generation_id FROM generations WHERE code='RG');
  s BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Isuzu D-Max%');
  e INT; sp BIGINT;
BEGIN
  INSERT INTO engines (engine_code,engine_name,displacement_cc,displacement_l,fuel_type,aspiration,cylinders)
    VALUES ('4JJ3-TCX','3.0L Turbo-Diesel DOHC',2999,3.0,'Diesel','Turbocharged (intercooled)',4) ON CONFLICT DO NOTHING;
  e:=(SELECT engine_id FROM engines WHERE engine_code='4JJ3-TCX');
  INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain) VALUES (g,2024,'GCC',e,'4WD') RETURNING vehicle_spec_id INTO sp;
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'Engine Oil','Diesel low-SAPS (service refill)',7.5,'L',s,'A','Verified','2026-06-12'),
   (sp,'Brake','Replace every 48 months',1.0,'L',s,'A','Verified','2026-06-12'),
   (sp,'Coolant',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL);
  INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'timing_type','Timing chain (DOHC; no belt)',s,'A','Verified','2026-06-12'),
   (sp,'fuel_tank_l','76 L (HDPE)',s,'A','Verified','2026-06-12'),
   (sp,'tire_size','255/65R17 / 265/60R18',s,'A','Verified','2026-06-12'),
   (sp,'differential_oil','Front 1.24 L / Rear 2.1 L',s,'A','Verified','2026-06-12');
  INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,normal_time_months,notes,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'Engine Oil & Filter',10000,24,'or 24 months',s,'A','Verified','2026-06-12'),
   (sp,'Engine Air Filter',30000,48,NULL,s,'A','Verified','2026-06-12');
  INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,source_id,confidence_grade,verification_status) VALUES
   (sp,TRUE,'GCC','Commercial diesel pickup — allowed in Lebanon',s,'A','Verified');
END $$;

-- Hyundai Tucson NX4 (Grade A fluids) — represent G2.0 variant
DO $$
DECLARE g INT:=(SELECT generation_id FROM generations WHERE code='NX4');
  s BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Hyundai Tucson%'); sp BIGINT;
BEGIN
  INSERT INTO vehicle_specs (generation_id,model_year,market,drivetrain) VALUES (g,2025,'GCC','AWD') RETURNING vehicle_spec_id INTO sp;
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'Engine Oil','SAE 0W-20; API SN PLUS/SP or ILSAC GF-6 (G2.0)',4.3,'L',s,'A','Verified','2026-06-12'),
   (sp,'Coolant','Ethylene-glycol antifreeze + water (G2.0)',6.4,'L',s,'A','Verified','2026-06-12'),
   (sp,'Transmission','ATF SP4M-1 (G2.0)',6.7,'L',s,'A','Verified','2026-06-12'),
   (sp,'Brake','DOT-4 LV / FMVSS116 DOT-4',0.82,'L',s,'A','Verified','2026-06-12');
  INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'fuel_tank_l','54 L',s,'A','Verified','2026-06-12'),
   (sp,'differential_oil','Rear (4WD) 0.53-0.63 L; API GL-5 75W/85',s,'A','Verified','2026-06-12'),
   (sp,'spark_plug_interval',NULL,NULL,NULL,'Not Verified',NULL);
END $$;

-- Kia Picanto JA (P1) — Grade A fluids from Middle East manual
DO $$
DECLARE g INT:=(SELECT generation_id FROM generations WHERE code='JA');
  s BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Kia Picanto%'); sp BIGINT;
BEGIN
  INSERT INTO vehicle_specs (generation_id,model_year,market,drivetrain) VALUES (g,2024,'GCC','FWD') RETURNING vehicle_spec_id INTO sp;
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'Engine Oil','SAE 0W-20 (5W-30 if 0W-20 unavailable); API Latest/ACEA A5/B5 (1.2 MPI)',3.5,'L',s,'A','Verified','2026-06-12'),
   (sp,'Coolant','Phosphate ethylene-glycol (1.2 MPI)',5.5,'L',s,'A','Verified','2026-06-12'),
   (sp,'Transmission','ATF SP-III (1.2 MPI auto)',6.1,'L',s,'A','Verified','2026-06-12'),
   (sp,'Brake','DOT-4 LV / FMVSS116 DOT-4',0.44,'L',s,'A','Verified','2026-06-12');
  INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'fuel_tank_l','35 L',s,'A','Verified','2026-06-12'),
   (sp,'spark_plug_interval',NULL,NULL,NULL,'Not Verified',NULL),
   (sp,'timing_type',NULL,NULL,NULL,'Not Verified',NULL);
  INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,recommended_octane,source_id,confidence_grade,verification_status) VALUES
   (sp,TRUE,'GCC',NULL,NULL,NULL,'Not Verified');
END $$;

-- Nissan Patrol Y63 (resolves generation decision) — Grade A engine/tank
DO $$
DECLARE g INT:=(SELECT generation_id FROM generations WHERE code='Y63');
  s BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Nissan Patrol Y63%');
  e INT; sp BIGINT;
BEGIN
  INSERT INTO engines (engine_code,engine_name,displacement_cc,displacement_l,fuel_type,aspiration,cylinders)
    VALUES ('VR35DDTT','3.5L V6 Twin-Turbo DIG',3492,3.5,'Petrol','Twin-turbocharged',6) ON CONFLICT DO NOTHING;
  e:=(SELECT engine_id FROM engines WHERE engine_code='VR35DDTT');
  INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain) VALUES (g,2025,'GCC',e,'4WD') RETURNING vehicle_spec_id INTO sp;
  INSERT INTO spec_performance (vehicle_spec_id,metric,value_numeric,unit,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'Power Output',425,'HP',s,'A','Verified','2026-06-12'),(sp,'Torque',700,'Nm',s,'A','Verified','2026-06-12');
  INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'fuel_tank_l','97 L',s,'A','Verified','2026-06-12'),
   (sp,'oil_coolant_intervals','Catalogue has no maintenance section — owner manual needed',NULL,NULL,'Not Verified',NULL);
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,verification_status) VALUES (sp,'Engine Oil','Not Verified'),(sp,'Coolant','Not Verified');
  INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,source_id,confidence_grade,verification_status) VALUES
   (sp,TRUE,'GCC','Y63 confirmed current GCC Patrol (supersedes Y62 V8)',s,'A','Verified');
END $$;
COMMIT;
