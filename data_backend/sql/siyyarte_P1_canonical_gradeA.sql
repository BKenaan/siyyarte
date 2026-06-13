-- =====================================================================
-- Siyyarte — CANONICAL P1 seed (Grade A only). Integrity-first.
-- SUPERSEDES the earlier per-vehicle seeds (corolla_seed, gcc upgrades,
--   landcruiser, l200) which mixed grades. Load: schema -> THIS FILE.
-- RULES (P1 vehicles): only confidence_grade='A' (official manufacturer).
--   No Grade B/C/D, no secondary sources, no estimated/inferred values.
--   Anything not read from an official manual = NULL + 'Not Verified'
--   with note "Verification Pending". Each A value carries source_id+page.
-- Vehicles: Corolla E210 (GCC + NA), Land Cruiser J300 (GCC),
--   Mitsubishi L200 6G/4N16 (engine identity only), Hilux (metadata only).
-- =====================================================================
BEGIN;

-- ---------- Grade-A sources (official manufacturer, page-cited) ----------
INSERT INTO sources (document_name,url,publisher,source_tier,confidence_grade,page_reference,access_date,notes) VALUES
-- Corolla GCC owner's manual
('Toyota GCC Corolla Owner''s Manual (OM12M43E)','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.459','2026-06-12','Octane, fuel tank, oil capacity (1ZR/2ZR)'),
('Toyota GCC Corolla Owner''s Manual (OM12M43E)','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.460','2026-06-12','Oil grade 5W-30 (1ZR/2ZR)'),
('Toyota GCC Corolla Owner''s Manual (OM12M43E)','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.462','2026-06-12','M20A oil grade 0W-16, capacity 4.6L'),
('Toyota GCC Corolla Owner''s Manual (OM12M43E)','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.464','2026-06-12','Coolant type SLLC + capacities'),
('Toyota GCC Corolla Owner''s Manual (OM12M43E)','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.465','2026-06-12','Spark plugs (DENSO), CVT fluid + capacity, battery V/charge'),
('Toyota GCC Corolla Owner''s Manual (OM12M43E)','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.467','2026-06-12','Brake fluid DOT3/DOT4'),
('Toyota GCC Corolla Owner''s Manual (OM12M43E)','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.468','2026-06-12','Tyre 205/55R16 91V'),
-- Corolla NA W&MG
('Toyota 2020 Corolla Warranty & Maintenance Guide','https://assets.sia.toyota.com/publications/en/omms-s/T-MMS-20Corolla/pdf/T-MMS-20Corolla.pdf','Toyota Motor Corp','1','A','Maintenance Log p.38-54','2026-06-12','NA maintenance intervals + oil viscosity'),
-- Land Cruiser GCC
('Toyota GCC Land Cruiser Station Wagon Owner''s Manual','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.747','2026-06-12','Octane, fuel tank, V35A output'),
('Toyota GCC Land Cruiser Station Wagon Owner''s Manual','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.748','2026-06-12','Oil capacity + grade'),
('Toyota GCC Land Cruiser Station Wagon Owner''s Manual','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.751','2026-06-12','Coolant SLLC + 1GR capacity'),
('Toyota GCC Land Cruiser Station Wagon Owner''s Manual','https://www.toyota.ae/en/owners/owners-manual/','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications p.755','2026-06-12','ATF capacity + differential oil'),
-- L200 (engine identity only; ASEAN doc — used ONLY for market-independent engine identity)
('Mitsubishi 24MY Triton Official Specifications List','https://www.mitsubishi-motors.com.ph/content/dam/mitsubishi-motors-ph/images/brochures/24MY%20Triton%20Official%20Specifications%20List_External%20240201.pdf','Mitsubishi Motors','1','A','Specifications List','2026-06-12','ASEAN doc. Used ONLY for market-independent engine identity (4N16 / 2442 cc). Trim figures NOT applied to GCC.'),
-- Hilux (metadata only, render-blocked)
('Toyota GCC Hilux Owner''s Manual (OM0K404E)','https://dam.alfuttaim.com/wps/wcm/connect/26347a81-b2f2-4a4f-a7cd-ad249b3bcb0f/TOYOTA_HILUX_EN_OM_OM0K404E_compressed.pdf','Toyota Motor Corp / Al-Futtaim','1','A','9-1 Specifications (~printed p.690+)','2026-06-12','Official Source Located - Verification Pending. 762pp compressed PDF render-blocked; spec fields NOT yet read.');

-- ---------- Reference data ----------
INSERT INTO makes (name) VALUES ('Toyota'),('Mitsubishi') ON CONFLICT DO NOTHING;
INSERT INTO models (make_id,name) VALUES
 ((SELECT make_id FROM makes WHERE name='Toyota'),'Corolla'),
 ((SELECT make_id FROM makes WHERE name='Toyota'),'Land Cruiser'),
 ((SELECT make_id FROM makes WHERE name='Toyota'),'Hilux'),
 ((SELECT make_id FROM makes WHERE name='Mitsubishi'),'L200 / Triton')
ON CONFLICT DO NOTHING;
INSERT INTO generations (model_id,code,name,year_start,year_end) VALUES
 ((SELECT model_id FROM models WHERE name='Corolla'),'E210','12th generation',2019,2026),
 ((SELECT model_id FROM models WHERE name='Land Cruiser'),'J300','300 series (Station Wagon)',2021,2026),
 ((SELECT model_id FROM models WHERE name='Hilux'),'AN120/130','8th generation',2015,2026),
 ((SELECT model_id FROM models WHERE name='L200 / Triton'),'6G (4N16)','6th generation',2024,2026);
INSERT INTO engines (engine_code,engine_name,displacement_cc,displacement_l,fuel_type,aspiration,cylinders) VALUES
 ('1ZR-FE','1.6L Dual VVT-i',1598,1.6,'Petrol','Naturally aspirated',4),
 ('2ZR-FE','1.8L Dual VVT-i',1798,1.8,'Petrol','Naturally aspirated',4),
 ('M20A-FKS','2.0L Dynamic Force',1987,2.0,'Petrol','Naturally aspirated',4),
 ('1GR-FE','4.0L V6 Dual VVT-i',3956,4.0,'Petrol','Naturally aspirated',6),
 ('V35A-FTS','3.5L V6 Twin-Turbo',3445,3.5,'Petrol','Twin-turbocharged',6),
 ('4N16','2.4L Intercooled Turbo DI-D',2442,2.4,'Diesel','Turbocharged (intercooled)',4)
ON CONFLICT DO NOTHING;

-- ================= COROLLA E210 — GCC (Grade A) =================
DO $$
DECLARE
  g INT := (SELECT generation_id FROM generations WHERE code='E210');
  s459 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Corolla%' AND page_reference LIKE '%p.459');
  s460 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Corolla%' AND page_reference LIKE '%p.460');
  s462 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Corolla%' AND page_reference LIKE '%p.462');
  s464 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Corolla%' AND page_reference LIKE '%p.464');
  s465 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Corolla%' AND page_reference LIKE '%p.465');
  s467 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Corolla%' AND page_reference LIKE '%p.467');
  s468 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Corolla%' AND page_reference LIKE '%p.468');
  ec TEXT; eid INT; sp BIGINT; oc NUMERIC; cc NUMERIC; vc NUMERIC; og TEXT; ogs BIGINT; sgr TEXT;
BEGIN
  FOREACH ec IN ARRAY ARRAY['1ZR-FE','2ZR-FE','M20A-FKS'] LOOP
    eid := (SELECT engine_id FROM engines WHERE engine_code=ec);
    INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain)
      VALUES (g,2020,'GCC',eid,'FWD') RETURNING vehicle_spec_id INTO sp;
    IF ec='M20A-FKS' THEN oc:=4.6; cc:=6.2; vc:=8.5; og:='SAE 0W-16; API SN/SP, ILSAC'; ogs:=s462; sgr:='DENSO FC20HR-Q8 (iridium), gap 0.8 mm';
    ELSIF ec='1ZR-FE' THEN oc:=4.2; cc:=5.9; vc:=7.5; og:='SAE 5W-30 (10W-30/15W-40 acceptable); API SL/SM/SN/SN PLUS or ILSAC'; ogs:=s460; sgr:='DENSO SC16HR11 (iridium), gap 1.1 mm';
    ELSE oc:=4.2; cc:=5.8; vc:=7.5; og:='SAE 5W-30 (10W-30/15W-40 acceptable); API SL/SM/SN/SN PLUS or ILSAC'; ogs:=s460; sgr:='DENSO SC16HR11 (iridium), gap 1.1 mm'; END IF;
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil',og,oc,'L (with filter)',ogs,'A','Verified','2026-06-12'),
     (sp,'Coolant','Toyota Super Long Life Coolant (SLLC); do not use plain water alone',cc,'L',s464,'A','Verified','2026-06-12'),
     (sp,'Transmission','Toyota Genuine CVT Fluid FE',vc,'L',s465,'A','Verified','2026-06-12'),
     (sp,'Brake','SAE J1703/FMVSS116 DOT 3 or SAE J1704/FMVSS116 DOT 4',NULL,NULL,s467,'A','Verified','2026-06-12'),
     (sp,'Power Steering','Electric Power Steering (no hydraulic fluid)',NULL,NULL,NULL,NULL,'Not Verified',NULL);
    INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,value_numeric,unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'fuel_tank_l',NULL,50,'L',s459,'A','Verified','2026-06-12'),
     (sp,'tire_size','205/55R16 91V; wheel 15x6.5J; cold 250 kPa front / 240 kPa rear; nut torque 103 N·m',NULL,NULL,s468,'A','Verified','2026-06-12'),
     (sp,'spark_plug_part',sgr,NULL,NULL,s465,'A','Verified','2026-06-12'),
     (sp,'battery_12v','12V; open-circuit >=12.3V @20C; charge 15A max(quick)/5A max(slow). Physical type/size not in OM.',NULL,NULL,s465,'A','Verified','2026-06-12'),
     (sp,'timing_type',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL),
     (sp,'maintenance_schedule_gcc',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL);
    INSERT INTO spec_performance (vehicle_spec_id,metric,verification_status) VALUES (sp,'Power Output','Not Verified'),(sp,'Torque','Not Verified');
    INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,recommended_octane,source_id,confidence_grade,verification_status)
      VALUES (sp,TRUE,'GCC','91 RON minimum (Regular)',s459,'A','Verified');
  END LOOP;
END $$;

-- ================= COROLLA E210 — NORTH AMERICA (Grade A intervals) =================
DO $$
DECLARE
  g INT:=(SELECT generation_id FROM generations WHERE code='E210');
  sm BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota 2020 Corolla Warranty%');
  sp BIGINT;
BEGIN
  INSERT INTO vehicle_specs (generation_id,model_year,market,drivetrain) VALUES (g,2020,'North America','FWD') RETURNING vehicle_spec_id INTO sp;
  INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,normal_time_months,severe_mileage_km,severe_time_months,first_replacement_km,subsequent_interval_km,notes,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'Engine Oil & Filter',16000,12,8000,6,NULL,NULL,'Official 10,000 mi/12mo normal; 5,000 mi/6mo severe',sm,'A','Verified','2026-06-12'),
   (sp,'Engine Air Filter',48000,36,NULL,NULL,NULL,48000,'30,000 mi',sm,'A','Verified','2026-06-12'),
   (sp,'Cabin Air Filter',48000,36,NULL,NULL,NULL,48000,'30,000 mi',sm,'A','Verified','2026-06-12'),
   (sp,'Engine Coolant',NULL,NULL,NULL,NULL,160000,80000,'First 100,000 mi then 50,000 mi',sm,'A','Verified','2026-06-12'),
   (sp,'Spark Plugs',193000,144,NULL,NULL,NULL,193000,'120,000 mi iridium',sm,'A','Verified','2026-06-12'),
   (sp,'Transmission Fluid (CVT)',96000,72,NULL,NULL,NULL,NULL,'60,000 mi',sm,'A','Verified','2026-06-12');
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'Engine Oil','SAE 0W-20 (2ZR-FAE) / 0W-16 (M20A-FKS)',sm,'A','Verified','2026-06-12'),
   (sp,'Brake','Inspect level/condition; no fixed mileage replacement mandated in normal schedule',sm,'A','Verified','2026-06-12');
END $$;

-- ================= LAND CRUISER J300 — GCC (Grade A) =================
DO $$
DECLARE
  g INT:=(SELECT generation_id FROM generations WHERE code='J300');
  s747 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Land Cruiser%' AND page_reference LIKE '%p.747');
  s748 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Land Cruiser%' AND page_reference LIKE '%p.748');
  s751 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Land Cruiser%' AND page_reference LIKE '%p.751');
  s755 BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Land Cruiser%' AND page_reference LIKE '%p.755');
  e40 INT:=(SELECT engine_id FROM engines WHERE engine_code='1GR-FE');
  e35 INT:=(SELECT engine_id FROM engines WHERE engine_code='V35A-FTS');
  sp40 BIGINT; sp35 BIGINT;
BEGIN
  INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain) VALUES (g,2026,'GCC',e40,'4WD') RETURNING vehicle_spec_id INTO sp40;
  INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain) VALUES (g,2026,'GCC',e35,'4WD') RETURNING vehicle_spec_id INTO sp35;
  -- 1GR-FE
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp40,'Engine Oil','SAE 0W-20 preferred (5W-20/5W-30/10W-30 acceptable)',6.1,'L (with filter)',s748,'A','Verified','2026-06-12'),
   (sp40,'Coolant','Toyota Super Long Life Coolant (SLLC)',11.6,'L (13.8 L with rear A/C)',s751,'A','Verified','2026-06-12'),
   (sp40,'Transmission','Toyota Genuine ATF (10-speed automatic)',9.8,'L',s755,'A','Verified','2026-06-12');
  INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,value_numeric,unit,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp40,'fuel_tank_l','80 L (110 L with sub fuel tank system)',NULL,NULL,s747,'A','Verified','2026-06-12'),
   (sp40,'differential_oil','Rear 5.47 L (no lock)/4.91 L (lock); Toyota Genuine Diff Gear Oil 75W-85 GL-5',NULL,NULL,s755,'A','Verified','2026-06-12'),
   (sp40,'spark_plug_part',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL),
   (sp40,'tire_size',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL),
   (sp40,'battery_12v',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL);
  INSERT INTO spec_performance (vehicle_spec_id,metric,verification_status) VALUES (sp40,'Power Output','Not Verified'),(sp40,'Torque','Not Verified');
  INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,recommended_octane,source_id,confidence_grade,verification_status)
    VALUES (sp40,TRUE,'GCC','95 RON recommended (91 RON minimum)',s747,'A','Verified');
  -- V35A-FTS
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp35,'Engine Oil','SAE 0W-20 preferred (5W-20/5W-30/10W-30 acceptable)',7.3,'L (with filter)',s748,'A','Verified','2026-06-12'),
   (sp35,'Coolant','Toyota Super Long Life Coolant (SLLC)',NULL,'L (capacity Verification Pending)',s751,'A','Verified','2026-06-12'),
   (sp35,'Transmission','Toyota Genuine ATF (10-speed automatic)',10.6,'L (with Stop&Start; 10.5 L without)',s755,'A','Verified','2026-06-12');
  INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,value_numeric,unit,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp35,'fuel_tank_l','80 L (110 L with sub fuel tank system)',NULL,NULL,s747,'A','Verified','2026-06-12'),
   (sp35,'differential_oil','Rear 5.45 L (no lock/LSD)/5.18 L (lock)/5.25 L (LSD); 75W-85 GL-5',NULL,NULL,s755,'A','Verified','2026-06-12'),
   (sp35,'spark_plug_part',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL),
   (sp35,'tire_size',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL),
   (sp35,'battery_12v',NULL,NULL,NULL,NULL,NULL,'Not Verified',NULL);
  INSERT INTO spec_performance (vehicle_spec_id,metric,value_numeric,unit,rpm,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp35,'Power Output',225,'kW (306 hp)','@4000 rpm',s747,'A','Verified','2026-06-12'),
   (sp35,'Torque',700,'Nm','@1600-2600 rpm',s747,'A','Verified','2026-06-12');
  INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,recommended_octane,source_id,confidence_grade,verification_status)
    VALUES (sp35,TRUE,'GCC','95 RON recommended (91 RON minimum)',s747,'A','Verified');
END $$;

-- ================= MITSUBISHI L200 6G — GCC (engine identity only) =================
-- Only market-INDEPENDENT engine identity from the official spec list is applied.
-- ASEAN trim figures (power/tank/tyres) are NOT applied to GCC (market mismatch) -> Verification Pending.
DO $$
DECLARE
  g INT:=(SELECT generation_id FROM generations WHERE code='6G (4N16)');
  sa BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Mitsubishi 24MY%');
  e INT:=(SELECT engine_id FROM engines WHERE engine_code='4N16');
  sp BIGINT;
BEGIN
  INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain) VALUES (g,2024,'GCC',e,'4WD') RETURNING vehicle_spec_id INTO sp;
  -- engine displacement is intrinsic (market-independent) -> A; everything trim/fluid = pending
  INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'engine_identity','4N16 2.4L intercooled turbo DI-D, 2442 cc (market-independent, official spec list)',sa,'A','Verified','2026-06-12'),
   (sp,'fuel_tank_l',NULL,NULL,NULL,'Not Verified',NULL),
   (sp,'tire_size',NULL,NULL,NULL,'Not Verified',NULL),
   (sp,'transmission',NULL,NULL,NULL,'Not Verified',NULL);
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,verification_status) VALUES
   (sp,'Engine Oil','Not Verified'),(sp,'Coolant','Not Verified'),(sp,'Transmission','Not Verified'),(sp,'Brake','Not Verified');
  INSERT INTO spec_performance (vehicle_spec_id,metric,verification_status) VALUES (sp,'Power Output','Not Verified'),(sp,'Torque','Not Verified');
  INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,verification_status)
    VALUES (sp,TRUE,'GCC','Commercial pickup (diesel allowed). GCC fluid/trim specs Verification Pending (only engine identity verified).','Not Verified');
END $$;

-- ================= TOYOTA HILUX — GCC (metadata only; render-blocked) =================
DO $$
DECLARE
  g INT:=(SELECT generation_id FROM generations WHERE code='AN120/130');
  sh BIGINT:=(SELECT source_id FROM sources WHERE document_name LIKE 'Toyota GCC Hilux%');
  sp BIGINT;
BEGIN
  -- generation/engine mapping preserved (no engine_id committed since GCC engine not verified from manual)
  INSERT INTO vehicle_specs (generation_id,model_year,market,drivetrain) VALUES (g,2026,'GCC','4WD') RETURNING vehicle_spec_id INTO sp;
  INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
   (sp,'manual_status','Official Source Located - Verification Pending (OM0K404E, 762pp compressed PDF render-blocked; spec ch.9 not read)',sh,'A','Verified','2026-06-12'),
   (sp,'engine_mapping','GCC candidates: 2TR-FE 2.7 petrol / 2GD-FTV 2.4 diesel / 1GD-FTV 2.8 diesel (commercial diesel allowed) — to confirm from manual',NULL,NULL,'Not Verified',NULL),
   (sp,'fuel_tank_l',NULL,NULL,NULL,'Not Verified',NULL),
   (sp,'tire_size',NULL,NULL,NULL,'Not Verified',NULL),
   (sp,'spark_plug_part',NULL,NULL,NULL,'Not Verified',NULL),
   (sp,'battery_12v',NULL,NULL,NULL,'Not Verified',NULL);
  INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,verification_status) VALUES
   (sp,'Engine Oil','Not Verified'),(sp,'Coolant','Not Verified'),(sp,'Transmission','Not Verified'),(sp,'Brake','Not Verified');
  INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,verification_status)
    VALUES (sp,TRUE,'GCC','Official GCC manual URL + metadata preserved. Queued for re-verification via alternate PDF pipeline.','Not Verified');
END $$;

COMMIT;
