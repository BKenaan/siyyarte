-- =====================================================================
-- Siyyarte — Phase 3A: GM/Ford scaled batch (Grade A, US-spec)
-- Suburban, Cadillac Escalade, Ford Expedition, Silverado 1500, Sierra 1500, Ford Edge
-- market='North America'. Field-level cited. No cross-copying, no secondary.
-- =====================================================================
BEGIN;
INSERT INTO makes (name) VALUES ('Cadillac') ON CONFLICT DO NOTHING;
INSERT INTO models (make_id,name) VALUES
 ((SELECT make_id FROM makes WHERE name='Chevrolet'),'Suburban'),
 ((SELECT make_id FROM makes WHERE name='Chevrolet'),'Silverado 1500'),
 ((SELECT make_id FROM makes WHERE name='Cadillac'),'Escalade'),
 ((SELECT make_id FROM makes WHERE name='GMC'),'Sierra 1500'),
 ((SELECT make_id FROM makes WHERE name='Ford'),'Expedition'),
 ((SELECT make_id FROM makes WHERE name='Ford'),'Edge')
ON CONFLICT DO NOTHING;
INSERT INTO generations (model_id,code,name,year_start,year_end) VALUES
 ((SELECT model_id FROM models WHERE name='Suburban'),'T1XX','12th gen',2021,2026),
 ((SELECT model_id FROM models WHERE name='Silverado 1500'),'T1XX','4th gen',2019,2026),
 ((SELECT model_id FROM models WHERE name='Escalade'),'T1XX','5th gen',2021,2026),
 ((SELECT model_id FROM models WHERE name='Sierra 1500'),'T1XX','4th gen',2019,2026),
 ((SELECT model_id FROM models WHERE name='Expedition'),'U553','4th gen',2018,2026),
 ((SELECT model_id FROM models WHERE name='Edge'),'CD539','2nd gen',2015,2024);
INSERT INTO engines (engine_code,engine_name,displacement_cc,displacement_l,fuel_type,aspiration,cylinders) VALUES
 ('L3B','2.7L Turbo I4',2700,2.7,'Petrol','Turbocharged',4),
 ('LT4','6.2L Supercharged V8',6200,6.2,'Petrol','Supercharged',8),
 ('Ford2.0EB','2.0L EcoBoost I4',2000,2.0,'Petrol','Turbocharged',4)
ON CONFLICT DO NOTHING;

INSERT INTO sources (document_name,url,publisher,source_tier,confidence_grade,page_reference,access_date,notes) VALUES
('2023 Chevrolet Tahoe/Suburban Owner Manual (US)','https://contentdelivery.ext.gm.com/.../23_CHEV_Tahoe_Suburban_OM_en_US_84979315B.pdf','General Motors','1','A','Capacities p.409; Maint p.402','2026-06-12','Covers Suburban (LWB rows); US-spec'),
('2023 Cadillac Escalade Owner Manual (US)','https://contentdelivery.ext.gm.com/content/dam/cope/en_us/public/pdf_assets/active/owners_manuals_browse/23_CAD_Escalade_OM_en_US_85619197C.pdf','General Motors','1','A','Capacities p.437; Maint p.427','2026-06-12','US-spec; incl. LT4 supercharged (Escalade-V)'),
('2022 Ford Expedition Owner Manual (US)','https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2022-Ford-Expedition-Owners-Manual-version-1_om_EN-US_11_2021.pdf','Ford Motor Co','1','A','Capacities p.455-459; Maint p.534','2026-06-12','US-spec'),
('2024 Chevrolet Silverado 1500 Owner Manual (US)','https://contentdelivery.ext.gm.com/.../24_CHEV_Silverado_1500_OM_en_US_85516379C.pdf','General Motors','1','A','Capacities p.436; Fuel p.301','2026-06-12','US-spec; 2.7/5.3/6.2'),
('2023 GMC Sierra 1500 Owner Manual (US)','https://contentdelivery.ext.gm.com/content/dam/cope/en_us/public/pdf_assets/active/owners_manuals_browse/23_GMC_Sierra_Sierra_Denali_1500_OM_en_US_84883874C.pdf','General Motors','1','A','Capacities p.441; Fuel p.306','2026-06-12','US-spec'),
('2022 Ford Edge Owner Manual (US)','https://www.fordservicecontent.com/Ford_Content/Catalog/owner_information/2022-Ford-Edge-Owners-Manual-version-1_om_EN-USA_09_2021.pdf','Ford Motor Co','1','A','Capacities p.353-357; Maint p.402','2026-06-12','US-spec; 2.0/2.7 EcoBoost');

-- GM full-size (Suburban, Escalade, Silverado, Sierra) + Ford (Expedition, Edge)
DO $$
DECLARE rec RECORD; sp BIGINT; src BIGINT;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    -- model, gcode, srclike, engine_code, oil_l, oilspec, coolant_l, tank_text, fuel_text, brake, drive
    ('Suburban','T1XX','2023 Chevrolet Tahoe%','L84',7.6,'dexos1 0W-20',14.8,'106 L (28 gal LWB)','87 AKI regular','DOT 4','4WD'),
    ('Suburban','T1XX','2023 Chevrolet Tahoe%','L87',7.6,'dexos1 0W-20',14.3,'106 L (28 gal LWB)','91 AKI premium recommended','DOT 4','4WD'),
    ('Escalade','T1XX','2023 Cadillac Escalade%','L87',7.6,'dexos1 0W-20',14.3,'90.8 L (SWB)/106 L (ESV)','91 AKI premium recommended (87 ok)','DOT 4','4WD'),
    ('Escalade','T1XX','2023 Cadillac Escalade%','LT4',7.6,'dexos1',14.6,'90.8/106 L','91 AKI premium recommended','DOT 4','4WD'),
    ('Silverado 1500','T1XX','2024 Chevrolet Silverado%','L3B',5.7,'dexos1',11.8,'90.8 L (24 gal)/107.1 L (long box)','87 AKI regular','DOT 4','4WD'),
    ('Silverado 1500','T1XX','2024 Chevrolet Silverado%','L84',7.6,'dexos1',13.1,'90.8/107.1 L','87 AKI regular','DOT 4','4WD'),
    ('Silverado 1500','T1XX','2024 Chevrolet Silverado%','L87',7.6,'dexos1',12.6,'90.8/107.1 L','91 AKI premium recommended','DOT 4','4WD'),
    ('Sierra 1500','T1XX','2023 GMC Sierra%','L3B',5.7,'dexos1',11.8,'90.8/107.1 L','87 AKI regular','DOT 4','4WD'),
    ('Sierra 1500','T1XX','2023 GMC Sierra%','L84',7.6,'dexos1',13.1,'90.8/107.1 L','87 AKI regular','DOT 4','4WD'),
    ('Sierra 1500','T1XX','2023 GMC Sierra%','L87',7.6,'dexos1',12.6,'90.8/107.1 L','91 AKI premium recommended','DOT 4','4WD'),
    ('Expedition','U553','2022 Ford Expedition%','Ford3.5EB',5.7,'Motorcraft 5W-30 (WSS-M2C961-A1)',15.1,'89.3 L/105.2 L (MAX)','87 AKI min; 91 recommended','DOT 4 LV','4WD'),
    ('Edge','CD539','2022 Ford Edge%','Ford2.0EB',5.2,'Motorcraft 5W-30 (WSS-M2C961-A1)',9.2,'69.7 L (FWD)/70 L (AWD)','87 AKI min; 91 recommended','DOT 4 LV','AWD'),
    ('Edge','CD539','2022 Ford Edge%','Ford2.7EB',5.7,'Motorcraft 5W-30 (WSS-M2C961-A1)',11.8,'70 L','87 AKI min; 91 recommended','DOT 4 LV','AWD')
  ) AS t(model,gcode,srclike,ecode,oil,oilspec,coolant,tank,fuel,brake,drive) LOOP
    src:=(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike);
    INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain)
      VALUES ((SELECT g.generation_id FROM generations g JOIN models m ON m.model_id=g.model_id WHERE m.name=rec.model AND g.code=rec.gcode),
              CASE WHEN rec.srclike LIKE '2024%' THEN 2024 ELSE 2023 END,'North America',
              (SELECT engine_id FROM engines WHERE engine_code=rec.ecode),rec.drive) RETURNING vehicle_spec_id INTO sp;
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil',rec.oilspec,rec.oil,'L (with filter)',src,'A','Verified','2026-06-12'),
     (sp,'Coolant',CASE WHEN rec.model IN ('Expedition','Edge') THEN 'Motorcraft Yellow Prediluted (WSS-M97B57-A2)' ELSE 'DEX-COOL 50/50' END,rec.coolant,'L',src,'A','Verified','2026-06-12'),
     (sp,'Transmission',CASE WHEN rec.model IN ('Expedition','Edge') THEN 'Motorcraft MERCON LV' ELSE 'DEXRON ULV (10-spd)' END,NULL,'L (fill qty not listed)',src,'A','Verified','2026-06-12'),
     (sp,'Brake',rec.brake,NULL,NULL,src,'A','Verified','2026-06-12');
    INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'fuel_tank_l',rec.tank,src,'A','Verified','2026-06-12'),
     (sp,'fuel_requirement',rec.fuel,src,'A','Verified','2026-06-12'),
     (sp,'tire_size',NULL,NULL,NULL,'Not Verified',NULL);
    -- maintenance: GM vs Ford differ
    IF rec.model IN ('Expedition','Edge') THEN
      INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,normal_time_months,notes,source_id,confidence_grade,verification_status,verification_date) VALUES
       (sp,'Engine Oil & Filter',16000,12,'IOLM up to 1yr/10,000 mi',src,'A','Verified','2026-06-12'),
       (sp,'Spark Plugs',160000,NULL,'100,000 mi',src,'A','Verified','2026-06-12'),
       (sp,'Engine Coolant',320000,NULL,'200,000 mi then 5yr/100k',src,'A','Verified','2026-06-12'),
       (sp,'Transmission Fluid',240000,NULL,'150,000 mi',src,'A','Verified','2026-06-12'),
       (sp,'Brake Fluid',NULL,36,'Every 3 years',src,'A','Verified','2026-06-12');
    ELSE
      INSERT INTO maintenance_items (vehicle_spec_id,item_name,normal_mileage_km,normal_time_months,notes,source_id,confidence_grade,verification_status,verification_date) VALUES
       (sp,'Engine Oil & Filter',NULL,12,'GM Oil Life System; min once/yr',src,'A','Verified','2026-06-12'),
       (sp,'Cabin Air Filter',36000,24,NULL,src,'A','Verified','2026-06-12'),
       (sp,'Brake Fluid',NULL,60,'Every 5 years (GM)',src,'A','Verified','2026-06-12');
    END IF;
    INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,source_id,confidence_grade,verification_status) VALUES
     (sp,TRUE,'North America','US-spec used import. Tyre on placard (NULL). Diesel variants via separate supplement.',src,'A','Verified');
  END LOOP;
END $$;
COMMIT;
