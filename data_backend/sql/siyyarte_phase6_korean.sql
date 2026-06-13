-- =====================================================================
-- Siyyarte — Phase 6: Korean GCC expansion (Grade A, open pipelines)
-- Hyundai en_GN (Gulf Nations) + Kia Middle East (D15/en_GB).
-- GCC proof: "For Middle East" oil rows / en_GN locale. Primary engine per model.
-- =====================================================================
BEGIN;
INSERT INTO makes (name) VALUES ('Hyundai'),('Kia') ON CONFLICT DO NOTHING;
INSERT INTO models (make_id,name) VALUES
 ((SELECT make_id FROM makes WHERE name='Hyundai'),'Kona'),
 ((SELECT make_id FROM makes WHERE name='Hyundai'),'Palisade'),
 ((SELECT make_id FROM makes WHERE name='Kia'),'K5 / Optima'),
 ((SELECT make_id FROM makes WHERE name='Kia'),'Seltos'),
 ((SELECT make_id FROM makes WHERE name='Kia'),'Telluride'),
 ((SELECT make_id FROM makes WHERE name='Kia'),'Pegas / Soluto'),
 ((SELECT make_id FROM makes WHERE name='Kia'),'Rio')
ON CONFLICT DO NOTHING;
INSERT INTO generations (model_id,code,name,year_start,year_end) VALUES
 ((SELECT model_id FROM models WHERE name='Kona'),'SX2','2nd gen',2023,2026),
 ((SELECT model_id FROM models WHERE name='Palisade'),'LX2','1st gen',2019,2026),
 ((SELECT model_id FROM models WHERE name='K5 / Optima'),'DL3','5th gen (K5)',2020,2026),
 ((SELECT model_id FROM models WHERE name='Seltos'),'SP2','1st gen (facelift SP3K)',2019,2026),
 ((SELECT model_id FROM models WHERE name='Telluride'),'ON','1st gen',2020,2026),
 ((SELECT model_id FROM models WHERE name='Pegas / Soluto'),'AB','1st gen',2017,2026),
 ((SELECT model_id FROM models WHERE name='Rio'),'SC','4th gen (YB/SC)',2017,2023);

INSERT INTO sources (document_name,url,publisher,source_tier,confidence_grade,page_reference,access_date,notes) VALUES
('Hyundai Kona SX2 Owner Manual (GCC en_GN)','https://ownersmanual.hyundai.com/full_webhelp/SX2/2024/en_GN/ideebd8cfc412.html','Hyundai Motor Co','1','A','Recommended lubricants & capacities','2026-06-13','en_GN Gulf Nations; "For Middle East" oil rows'),
('Hyundai Palisade LX2 Owner Manual (GCC en_GN)','https://ownersmanual.hyundai.com/full_webhelp/LX2/2024/en_GN/id80855141b3f.html','Hyundai Motor Co','1','A','Recommended lubricants & capacities','2026-06-13','en_GN Gulf Nations'),
('Kia K5 DL3 Owner Manual (GCC D15/en_GB)','https://ownersmanual.kia.com/full_webhelp/DL3/2022/en_GB/topics/chapter9_8.html','Kia Corp','1','A','chapter9_8 lubricants & capacities','2026-06-13','GCC locale D15 (Saudi); "For Middle East" oil rows'),
('Kia Seltos SP3K Owner Manual (GCC D15/en_GB)','https://ownersmanual.kia.com/full_webhelp/SP3K/2027/en_GB/topics/t00024.html','Kia Corp','1','A','t00024 lubricants & capacities','2026-06-13','GCC D15; "For Middle East" oil rows'),
('Kia Telluride ON Owner Manual (GCC D15/en_GB)','https://ownersmanual.kia.com/full_webhelp/ON/2025/en_GB/topics/chapter9_8.html','Kia Corp','1','A','chapter9_8','2026-06-13','GCC D15 locale'),
('Kia Pegas/Soluto AB Owner Manual (GCC D15/en_GB)','https://ownersmanual.kia.com/full_webhelp/AB/2026/en_GB/topics/chapter10_7.html','Kia Corp','1','A','chapter10_7','2026-06-13','GCC D15; "For Middle East" oil row'),
('Kia Rio SC Owner Manual (GCC D15/en_GB)','https://ownersmanual.kia.com/full_webhelp/SC/2020/en_GB/','Kia Corp','1','A','lubricants (capacities render-blocked)','2026-06-13','GCC D15; ME oil spec only; numeric capacities Blocked_OCR');

INSERT INTO engines (engine_code,engine_name,displacement_cc,displacement_l,fuel_type,aspiration,cylinders) VALUES
 ('Kona2.0','2.0L Atkinson MPI',1999,2.0,'Petrol','Naturally aspirated',4),
 ('Pal3.8','3.8L GDI V6 (Lambda)',3778,3.8,'Petrol','Naturally aspirated',6),
 ('K5-2.5','2.5L GDi (Theta III)',2497,2.5,'Petrol','Naturally aspirated',4),
 ('Seltos2.0','2.0L MPI (Nu)',1999,2.0,'Petrol','Naturally aspirated',4),
 ('Tell3.8','3.8L GDi V6 (Lambda II)',3778,3.8,'Petrol','Naturally aspirated',6),
 ('Pegas1.4','1.4L MPI (Kappa)',1368,1.4,'Petrol','Naturally aspirated',4),
 ('Rio1.4','1.4L MPI (Kappa)',1368,1.4,'Petrol','Naturally aspirated',4)
ON CONFLICT DO NOTHING;

DO $$
DECLARE rec RECORD; sp BIGINT; src BIGINT;
BEGIN
  FOR rec IN SELECT * FROM (VALUES
    -- model, gcode, year, srclike, engine_code, oilspec, oil, coolant, transspec, transcap, brake, tank, blocked
    ('Kona','SX2',2024,'Hyundai Kona%','Kona2.0','5W-30 ACEA A5/B5 (For Middle East)',4.3,6.9,'IVT SP-CVT1',6.7,'DOT-4',47,false),
    ('Palisade','LX2',2024,'Hyundai Palisade%','Pal3.8','ACEA A5/B5',6.5,11.98,'ATF SP4M-1',7.0,'DOT-4 LV',71,false),
    ('K5 / Optima','DL3',2022,'Kia K5%','K5-2.5','0W-30 API SN+/SP or ILSAC GF-6 (For Middle East)',5.8,9.4,'ATF SP-IV',6.5,'DOT 4',60,false),
    ('Seltos','SP2',2025,'Kia Seltos%','Seltos2.0','5W-30/0W-30 ACEA A5/B5 or API SN+/SP (For Middle East)',4.3,6.5,'IVT SP-CVT1',6.7,'DOT-4 LV',50,false),
    ('Telluride','ON',2025,'Kia Telluride%','Tell3.8','SAE 5W-30 ACEA A5',6.5,12.2,'ATF SP4M-1',7.0,'DOT-4 LV',71,false),
    ('Pegas / Soluto','AB',2026,'Kia Pegas%','Pegas1.4','5W-30 ACEA A5/B5 (For Middle East)',3.5,5.3,'ATF SP-III',6.1,'DOT-4',43,false),
    ('Rio','SC',2020,'Kia Rio%','Rio1.4','ACEA A5/B5 (For Middle East)',NULL,NULL,NULL,NULL,'DOT-3 or DOT-4',NULL,true)
  ) AS t(model,gcode,yr,srclike,ecode,oilspec,oil,coolant,transspec,transcap,brake,tank,blocked) LOOP
    src:=(SELECT source_id FROM sources WHERE document_name LIKE rec.srclike);
    INSERT INTO vehicle_specs (generation_id,model_year,market,engine_id,drivetrain)
      VALUES ((SELECT g.generation_id FROM generations g JOIN models m ON m.model_id=g.model_id WHERE m.name=rec.model AND g.code=rec.gcode),
              rec.yr,'GCC',(SELECT engine_id FROM engines WHERE engine_code=rec.ecode),'FWD') RETURNING vehicle_spec_id INTO sp;
    -- engine oil spec ALWAYS verified (even Rio); capacity may be NULL/blocked
    INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
     (sp,'Engine Oil',rec.oilspec,rec.oil,CASE WHEN rec.oil IS NULL THEN 'L (capacity Blocked_OCR)' ELSE 'L' END,src,'A','Verified','2026-06-13');
    IF NOT rec.blocked THEN
      INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,capacity_value,capacity_unit,source_id,confidence_grade,verification_status,verification_date) VALUES
       (sp,'Coolant','Phosphate ethylene-glycol',rec.coolant,'L',src,'A','Verified','2026-06-13'),
       (sp,'Transmission',rec.transspec,rec.transcap,'L',src,'A','Verified','2026-06-13'),
       (sp,'Brake',rec.brake,NULL,NULL,src,'A','Verified','2026-06-13');
      INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,value_numeric,unit,source_id,confidence_grade,verification_status,verification_date) VALUES
       (sp,'fuel_tank_l',NULL,rec.tank::numeric,'L',src,'A','Verified','2026-06-13');
    ELSE
      INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,specification,source_id,confidence_grade,verification_status,verification_date) VALUES
       (sp,'Brake',rec.brake,src,'A','Verified','2026-06-13');
      INSERT INTO spec_fluids (vehicle_spec_id,fluid_type,verification_status) VALUES (sp,'Coolant','Not Verified'),(sp,'Transmission','Not Verified');
      INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,verification_status) VALUES (sp,'fuel_tank_l',NULL,'Not Verified');
    END IF;
    INSERT INTO spec_attributes (vehicle_spec_id,attribute_key,value_text,verification_status) VALUES (sp,'spark_plug_interval',NULL,'Not Verified');
    INSERT INTO lebanon_market_info (vehicle_spec_id,is_common_import,variant_origin,notes,source_id,confidence_grade,verification_status) VALUES
     (sp,TRUE,'GCC','GCC-proof: '||CASE WHEN rec.oilspec ILIKE '%Middle East%' THEN '"For Middle East" oil row' ELSE 'en_GN/D15 Gulf locale' END||'. Additional engines available (primary engine recorded).',src,'A','Verified');
  END LOOP;
END $$;
COMMIT;
