-- =====================================================================
-- Siyyarte — Phase 7: American US-spec expansion (Grade A)
-- Equinox, Escape, Traverse, Terrain, Acadia, Mustang. market=North America.
-- Per-engine where applicable. QUEUED intervals = NULL/Not Verified (honest).
-- =====================================================================
BEGIN;
INSERT INTO makes (name) VALUES ('Chevrolet'),('GMC'),('Ford') ON CONFLICT DO NOTHING;
INSERT INTO models (make_id,name) VALUES
 ((SELECT make_id FROM makes WHERE name='Chevrolet'),'Equinox'),
 ((SELECT make_id FROM makes WHERE name='Chevrolet'),'Traverse'),
 ((SELECT make_id FROM makes WHERE name='GMC'),'Terrain'),
 ((SELECT make_id FROM makes WHERE name='GMC'),'Acadia'),
 ((SELECT make_id FROM makes WHERE name='Ford'),'Escape'),
 ((SELECT make_id FROM makes WHERE name='Ford'),'Mustang')
ON CONFLICT DO NOTHING;
INSERT INTO generations (model_id,code,name,year_start,year_end) VALUES
 ((SELECT model_id FROM models WHERE name='Equinox'),'3GEN','3rd gen',2018,2024),
 ((SELECT model_id FROM models WHERE name='Traverse'),'C1XX','2nd gen',2018,2023),
 ((SELECT model_id FROM models WHERE name='Terrain'),'3GEN','3rd gen',2018,2024),
 ((SELECT model_id FROM models WHERE name='Acadia'),'C1XX','2nd gen',2017,2024),
 ((SELECT model_id FROM models WHERE name='Escape'),'CX482','4th gen',2020,2026),
 ((SELECT model_id FROM models WHERE name='Mustang'),'S550','6th gen',2015,2023);
INSERT INTO engines (engine_code,engine_name,displacement_cc,displacement_l,fuel_type,aspiration,cylinders) VALUES
 ('GM1.5T','1.5L Turbo I4',1500,1.5,'Petrol','Turbocharged',4),
 ('GM3.6V6','3.6L V6 (LFY)',3600,3.6,'Petrol','Naturally aspirated',6),
 ('GM2.0T-LSY','2.0L Turbo I4 (LSY)',2000,2.0,'Petrol','Turbocharged',4),
 ('Ford1.5EB','1.5L EcoBoost I3',1500,1.5,'Petrol','Turbocharged',3),
 ('Ford2.5HEV','2.5L Atkinson Hybrid',2500,2.5,'Hybrid','Naturally aspirated',4),
 ('Ford2.3EB-S','2.3L EcoBoost (Mustang)',2300,2.3,'Petrol','Turbocharged',4),
 ('Ford5.0-S','5.0L V8 Coyote (Mustang)',5000,5.0,'Petrol','Naturally aspirated',8)
ON CONFLICT DO NOTHING;

INSERT INTO sources (document_name,url,publisher,source_tier,confidence_grade,page_reference,access_date,notes) VALUES
('2023 Chevrolet Equinox Owner Manual (US)','https://contentdelivery.ext.gm.com/.../23_CHEV_Equinox_OM_en_US_84895933B.pdf','General Motors','1','A','Capacities p.326; Maint p.319','2026-06-13','US-spec; engine displacement not in manual (label)'),
('2023 Chevrolet Traverse Owner Manual (US)','https://contentdelivery.ext.gm.com/.../23_CHEV_Traverse_OM_en_US_84999704B.pdf','General Motors','1','A','Capacities p.334; Maint p.327','2026-06-13','US-spec; 3.6L V6'),
('2022 GMC Terrain Owner Manual (US)','https://www.gmc.com/ownercenter/content/dam/gmownercenter/gmna/dynamic/manuals/2022/gmc/terrain/2022-gmc-terrain-owners-manual.pdf','General Motors','1','A','Capacities p.351','2026-06-13','US-spec; intervals QUEUED (matrix schedule)'),
('2022 GMC Acadia Owner Manual (US)','https://www.gmc.com/ownercenter/content/dam/gmownercenter/gmna/dynamic/manuals/2022/gmc/acadia/2022-gmc-acadia-owners-manual.pdf','General Motors','1','A','Capacities p.357-359','2026-06-13','US-spec; 2.0L+3.6L; intervals QUEUED'),
('2022 Ford Escape Owner Manual (US)','https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2022-Ford-Escape-Owners-Manual-version-1_om_EN-USA_09.2-2021.pdf','Ford Motor Co','1','A','Capacities p.395-402; Maint p.485-492','2026-06-13','US-spec; 1.5/2.0 EcoBoost + 2.5 HEV/PHEV'),
('2023 Ford Mustang Owner Manual (US)','https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2023_Ford_Mustang_Owners_Manual_version_1_om_EN-US.pdf','Ford Motor Co','1','A','Capacities p.349-368; Maint p.452-461','2026-06-13','US-spec; 2.3 EcoBoost + 5.0 V8; per-engine coolant NULL');

DO $$
DECLARE rec RECORD; sp BIGINT; src BIGINT;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    -- model,gcode,srclike,ecode,oil,oilspec,coolant,tank,trans,brake,octane,spark,oilint
    ('Equinox','3GEN','2023 Chevrolet Equinox%','GM1.5T',4.0,'dexos1 full synthetic',6.6,'56 L FWD / 59 L AWD','DEXRON-VI','DOT 4','87 AKI',96000,NULL),
    ('Traverse','C1XX','2023 Chevrolet Traverse%','GM3.6V6',5.7,'dexos1',14.6,'73.4 L FWD / 82.1 L AWD','DEXRON-VI','DOT 4','87 AKI',156000,NULL),
    ('Terrain','3GEN','2022 GMC Terrain%','GM1.5T',4.0,'dexos1',6.6,'56 L FWD / 59 L AWD','DEXRON-VI','DOT 4','87 AKI',NULL,NULL),
    ('Acadia','C1XX','2022 GMC Acadia%','GM3.6V6',5.7,'dexos1',10.6,'73.4 L FWD / 82.1 L AWD','DEXRON-VI','DOT 4','87 AKI',NULL,NULL),
    ('Escape','CX482','2022 Ford Escape%','Ford1.5EB',5.05,'5W-20 (WSS-M2C960-A1)',7.2,'56.2 L FWD / 59.5 L AWD','owner-spec n/a','DOT 4 LV','87 AKI',160000,16000),
    ('Mustang','S550','2023 Ford Mustang%','Ford5.0-S',9.5,'0W-30 (WSS-M2C963-A1)',NULL,'60.55 L (16 gal)','MERCON LV 14.4 L','DOT 4 LV','87 AKI min; 91+ premium',160000,NULL)
  ) AS t(model,gcode,srclike,ecode,oil,oilspec,coolant,tank,trans,brake,octane,spark,oilint) LOOP
    src:=(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike);
    INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain)
      VALUES ((SELECT g.generation_id FROM generations g JOIN models m ON m.model_id=g.model_id WHERE m.name=rec.model AND g.code=rec.gcode),
              CASE WHEN rec.srclike LIKE '2022%' THEN 2022 ELSE 2023 END,'North America',
              (SELECT engine_id FROM engines WHERE engine_code=rec.ecode),
              (CASE WHEN rec.model='Mustang' THEN 'RWD' ELSE 'AWD' END)::drivetrain_type) RETURNING vehicle_spec_id INTO sp;
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil',rec.oilspec,rec.oil,'L (with filter; FWD value where it differs)',src,'A','Verified','2026-06-13'),
     (sp,'Brake',rec.brake,NULL,NULL,src,'A','Verified','2026-06-13');
    IF rec.coolant IS NOT NULL THEN
      INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date)
      VALUES (sp,'Coolant',CASE WHEN rec.model IN ('Escape','Mustang') THEN 'Motorcraft Yellow Prediluted' ELSE 'DEX-COOL 50/50' END,rec.coolant,'L',src,'A','Verified','2026-06-13');
    ELSE
      INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,verification_status) VALUES (sp,'Coolant','Not Verified');
    END IF;
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,source_id,confidence_grade,verification_status,verification_date)
      VALUES (sp,'Transmission',rec.trans,src,'A','Verified','2026-06-13');
    INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'fuel_tank_l',rec.tank,src,'A','Verified','2026-06-13'),
     (sp,'fuel_requirement',rec.octane,src,'A','Verified','2026-06-13'),
     (sp,'tire_size',NULL,NULL,NULL,'Not Verified',NULL);
    -- maintenance: only where extracted (spark/oil); QUEUED intervals stay absent
    IF rec.spark IS NOT NULL THEN
      INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,notes,source_id,confidence_grade,verification_status,verification_date)
      VALUES (sp,'Spark Plugs',rec.spark,NULL,src,'A','Verified','2026-06-13');
    END IF;
    IF rec.oilint IS NOT NULL THEN
      INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,normal_time_months,notes,source_id,confidence_grade,verification_status,verification_date)
      VALUES (sp,'Engine Oil & Filter',rec.oilint,12,'IOLM',src,'A','Verified','2026-06-13');
    ELSE
      INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_time_months,notes,source_id,confidence_grade,verification_status,verification_date)
      VALUES (sp,'Engine Oil & Filter',12,'GM Oil Life System (algorithmic); min once/yr',src,'A','Verified','2026-06-13');
    END IF;
    INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,source_id,confidence_grade,verification_status) VALUES
     (sp,TRUE,'North America','US-spec used import. Tyre on placard (NULL).'||CASE WHEN rec.model IN ('Terrain','Acadia') THEN ' Intervals QUEUED (matrix schedule).' ELSE '' END,src,'A','Verified');
  END LOOP;
END $$;

-- ---------- Unsupported-vehicle capture flow (Workstream G) ----------
CREATE TABLE unsupported_vehicle_requests (
    request_id      BIGSERIAL PRIMARY KEY,
    submitted_at    TIMESTAMPTZ DEFAULT now(),
    brand           TEXT, model TEXT, model_year INT, trim TEXT, engine TEXT,
    market_origin   TEXT,                 -- user-stated (US/GCC/EU/Japan/unknown)
    vin_hash        CHAR(64),             -- SHA-256 of VIN; raw VIN NEVER stored here
    odometer_unit   TEXT CHECK (odometer_unit IN ('km','miles','unknown')),
    user_country    TEXT,
    import_source   TEXT,
    notify_email_hash CHAR(64),           -- hashed contact for "notify when available"
    status          TEXT DEFAULT 'NEW'
);
COMMENT ON TABLE unsupported_vehicle_requests IS 'Privacy: store ONLY vin_hash (SHA-256), never raw VIN. Drives demand-led coverage expansion.';
-- demand view: most-requested unsupported vehicles
CREATE OR REPLACE VIEW v_unsupported_demand AS
  SELECT brand, model, COUNT(*) requests FROM unsupported_vehicle_requests
  GROUP BY brand, model ORDER BY requests DESC;
COMMIT;
