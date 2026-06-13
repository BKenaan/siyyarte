-- =====================================================================
-- Siyyarte — OPERATING CONDITIONS model (Lebanese climate/usage profile)
-- Maps real Lebanese conditions (dust, heat, coastal salt/humidity, stop-go
-- idling) to the maintenance items each accelerates, with adjusted intervals.
-- Grade-A effects come from Toyota's official Special Operating Conditions
-- schedule; climate effects the US manual does NOT cover are flagged as
-- 'General engineering guidance' and Not Verified (GCC/Toyota ME = upgrade path).
-- Requires siyyarte_schema.sql + NA Grade-A seed (for vehicle_specs).
-- =====================================================================
BEGIN;

-- ---------- DDL extension ----------
CREATE TABLE operating_conditions (
    condition_id SERIAL PRIMARY KEY,
    code         TEXT UNIQUE NOT NULL,   -- DUST, HEAT, SALT_HUMIDITY, STOP_GO_IDLING, TOWING, COLD_SHORT_TRIP
    name         TEXT NOT NULL,
    description  TEXT
);

CREATE TABLE lebanon_regions (
    region_id       SERIAL PRIMARY KEY,
    name            TEXT NOT NULL,
    climate_summary TEXT,
    elevation_band  TEXT
);

CREATE TABLE region_conditions (        -- which conditions dominate in each region
    region_id    INT NOT NULL REFERENCES lebanon_regions(region_id) ON DELETE CASCADE,
    condition_id INT NOT NULL REFERENCES operating_conditions(condition_id) ON DELETE CASCADE,
    severity     TEXT CHECK (severity IN ('Dominant','Moderate','Minor')),
    PRIMARY KEY (region_id, condition_id)
);

CREATE TABLE condition_effects (
    id                 BIGSERIAL PRIMARY KEY,
    vehicle_spec_id    BIGINT REFERENCES vehicle_specs(vehicle_spec_id) ON DELETE CASCADE, -- NULL = generic rule
    condition_id       INT NOT NULL REFERENCES operating_conditions(condition_id),
    affected_item      TEXT NOT NULL,
    effect_description TEXT,
    adjusted_mileage_km INT,
    adjusted_time_months INT,
    basis              TEXT,             -- 'Manufacturer severe schedule' | 'General engineering guidance'
    source_id          BIGINT REFERENCES sources(source_id),
    confidence_grade   confidence_grade,
    verification_status verification_status NOT NULL DEFAULT 'Not Verified',
    verification_date  DATE
);
CREATE INDEX idx_condeffects_spec ON condition_effects(vehicle_spec_id);
CREATE INDEX idx_condeffects_cond ON condition_effects(condition_id);
COMMENT ON TABLE condition_effects IS 'Lebanon defaults to severe. Grade A rows are manufacturer-sourced; climate rows the OEM US manual omits are flagged General engineering guidance / Not Verified.';

-- ---------- Seed: conditions ----------
INSERT INTO operating_conditions (code,name,description) VALUES
('DUST','Dust / dirt roads','Airborne dust and unsealed/dusty roads — loads air filter and oil; common Bekaa & construction areas'),
('HEAT','Sustained high heat','Hot Mediterranean/inland summers — shortens 12V battery life, stresses coolant and AC, accelerates oil oxidation'),
('SALT_HUMIDITY','Coastal salt + humidity','Sea-air salt and high humidity along the coast — accelerates corrosion of brake/fuel lines, underbody and body'),
('STOP_GO_IDLING','Stop-go / extensive idling','Dense urban traffic (Beirut) and low-speed driving — Toyota severe category; reinforces CVT fluid and oil changes'),
('TOWING','Towing / heavy load','Towing or heavy loading — Toyota severe category; triggers transmission fluid replacement'),
('COLD_SHORT_TRIP','Cold / short trips','Repeated short trips in cold (Mount Lebanon winters/altitude) — moisture in oil, battery strain');

-- ---------- Seed: Lebanese regions + dominant conditions ----------
INSERT INTO lebanon_regions (name,climate_summary,elevation_band) VALUES
('Beirut & Coastal','Humid Mediterranean; hot humid summers, mild winters; dense traffic','0-100 m'),
('Bekaa Valley','Semi-arid continental; hot dry dusty summers, cold winters','800-1000 m'),
('Mount Lebanon','Cooler at altitude; cold/snowy winters, mild summers','700-2000 m'),
('North Coast (Tripoli)','Humid coastal; hot summers, salt air','0-100 m'),
('South Coast (Tyre/Saida)','Humid coastal; hot summers, salt air','0-100 m');

INSERT INTO region_conditions (region_id, condition_id, severity)
SELECT r.region_id, c.condition_id, v.sev FROM (VALUES
 ('Beirut & Coastal','HEAT','Dominant'),('Beirut & Coastal','SALT_HUMIDITY','Dominant'),('Beirut & Coastal','STOP_GO_IDLING','Dominant'),('Beirut & Coastal','DUST','Moderate'),
 ('Bekaa Valley','DUST','Dominant'),('Bekaa Valley','HEAT','Dominant'),('Bekaa Valley','COLD_SHORT_TRIP','Moderate'),('Bekaa Valley','SALT_HUMIDITY','Minor'),
 ('Mount Lebanon','COLD_SHORT_TRIP','Dominant'),('Mount Lebanon','DUST','Moderate'),('Mount Lebanon','HEAT','Minor'),
 ('North Coast (Tripoli)','SALT_HUMIDITY','Dominant'),('North Coast (Tripoli)','HEAT','Dominant'),('North Coast (Tripoli)','STOP_GO_IDLING','Moderate'),
 ('South Coast (Tyre/Saida)','SALT_HUMIDITY','Dominant'),('South Coast (Tyre/Saida)','HEAT','Dominant'),('South Coast (Tyre/Saida)','DUST','Moderate')
) AS v(region,code,sev)
JOIN lebanon_regions r ON r.name=v.region
JOIN operating_conditions c ON c.code=v.code;

-- ---------- Seed: Corolla condition effects ----------
INSERT INTO sources (document_name,url,publisher,source_tier,confidence_grade,page_reference,access_date,notes) VALUES
('Toyota 2020 Corolla W&MG — Special Operating Conditions','https://assets.sia.toyota.com/publications/en/omms-s/T-MMS-20Corolla/pdf/T-MMS-20Corolla.pdf','Toyota Motor Corporation','1','A','Maintenance Log p.54 (Additional Items for Special Operating Conditions)','2026-06-12','Per-condition severe additions: dusty/idling/towing');

DO $$
DECLARE
  s_sev BIGINT := (SELECT source_id FROM sources WHERE page_reference LIKE 'Maintenance Log p.54 (Additional%');
  s_oil BIGINT := (SELECT source_id FROM sources WHERE page_reference='Maintenance Log p.38');
  sp18  BIGINT := (SELECT vehicle_spec_id FROM vehicle_specs vs JOIN engines e ON e.engine_id=vs.engine_id
                   WHERE vs.market='North America' AND e.engine_code='2ZR-FAE' LIMIT 1);
  c_dust INT := (SELECT condition_id FROM operating_conditions WHERE code='DUST');
  c_heat INT := (SELECT condition_id FROM operating_conditions WHERE code='HEAT');
  c_salt INT := (SELECT condition_id FROM operating_conditions WHERE code='SALT_HUMIDITY');
  c_idle INT := (SELECT condition_id FROM operating_conditions WHERE code='STOP_GO_IDLING');
  c_tow  INT := (SELECT condition_id FROM operating_conditions WHERE code='TOWING');
BEGIN
  -- GRADE A (manufacturer severe schedule)
  INSERT INTO condition_effects (vehicle_spec_id,condition_id,affected_item,effect_description,adjusted_mileage_km,adjusted_time_months,basis,source_id,confidence_grade,verification_status,verification_date) VALUES
  (sp18,c_dust,'Engine Oil & Filter','Severe interval applies on dusty roads',8000,6,'Manufacturer severe schedule',s_oil,'A','Verified','2026-06-12'),
  (sp18,c_dust,'Chassis nuts & bolts','Tighten nuts/bolts on chassis and body (dusty/dirt roads)',NULL,NULL,'Manufacturer severe schedule',s_sev,'A','Verified','2026-06-12'),
  (sp18,c_idle,'Engine Oil & Filter','Severe interval applies in stop-go/extensive idling',8000,6,'Manufacturer severe schedule',s_oil,'A','Verified','2026-06-12'),
  (sp18,c_idle,'CVT Fluid','Replace CVT fluid — added requirement under extensive idling/low-speed (taxi-type) use',NULL,NULL,'Manufacturer severe schedule',s_sev,'A','Verified','2026-06-12'),
  (sp18,c_tow,'Transmission Fluid','Replace transmission fluid/oil when towing/heavy load',NULL,NULL,'Manufacturer severe schedule',s_sev,'A','Verified','2026-06-12');

  -- GENERAL ENGINEERING GUIDANCE (NOT in US manual — flagged, Not Verified, generic)
  INSERT INTO condition_effects (vehicle_spec_id,condition_id,affected_item,effect_description,adjusted_mileage_km,adjusted_time_months,basis,source_id,confidence_grade,verification_status) VALUES
  (NULL,c_dust,'Engine Air Filter','Inspect/replace more often than 48,000 km under heavy dust; figure pending GCC/Toyota-ME source',NULL,NULL,'General engineering guidance',NULL,'D','Not Verified'),
  (NULL,c_heat,'12V Battery','Sustained heat shortens life (~2-3 yr vs 4-5 yr temperate); inspect/expect earlier replacement',NULL,NULL,'General engineering guidance',NULL,'D','Not Verified'),
  (NULL,c_heat,'Engine Coolant','Verify coolant condition & boil/freeze protection more frequently in sustained heat',NULL,NULL,'General engineering guidance',NULL,'D','Not Verified'),
  (NULL,c_salt,'Brake/Fuel Lines & Underbody','Coastal salt + humidity accelerate corrosion — inspect lines, underbody, body at each service',NULL,NULL,'General engineering guidance',NULL,'D','Not Verified');
END $$;

COMMIT;
