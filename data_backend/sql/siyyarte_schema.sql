-- =====================================================================
-- Siyyarte (سيارتي) — Vehicle Maintenance Database
-- PostgreSQL schema  |  normalized + FIELD-LEVEL provenance
-- Scales to millions of vehicle_spec records.
-- Core rule: every measured/spec value carries its own source +
-- confidence grade (A/B/C/D). Unverified => value NULL, status 'Not Verified'.
-- =====================================================================
BEGIN;

-- ---------- ENUM types ----------
CREATE TYPE confidence_grade AS ENUM ('A','B','C','D');
-- A = Official Manufacturer | B = Government/Regulatory
-- C = Dealer Documentation  | D = Secondary Verified
CREATE TYPE source_tier       AS ENUM ('1','2','3');
CREATE TYPE verification_status AS ENUM ('Verified','Not Verified');
CREATE TYPE fuel_type         AS ENUM ('Petrol','Diesel','Hybrid','PHEV','Electric','CNG');
CREATE TYPE market_region     AS ENUM ('GCC','Europe','North America','Japan','Lebanon Import','Other');
CREATE TYPE drivetrain_type   AS ENUM ('FWD','RWD','AWD','4WD');

-- ---------- Source registry (normalized; referenced field-level) ----------
CREATE TABLE sources (
    source_id        BIGSERIAL PRIMARY KEY,
    document_name    TEXT NOT NULL,
    url              TEXT,
    publisher        TEXT,
    source_tier      source_tier,
    confidence_grade confidence_grade NOT NULL,   -- A/B/C/D class of this source
    page_reference   TEXT,
    access_date      DATE NOT NULL,
    notes            TEXT
);
COMMENT ON TABLE sources IS 'One row per cited document. Field-level rows reference source_id so URLs are not duplicated across millions of records.';

-- ---------- Reference / identity tables ----------
CREATE TABLE makes (
    make_id   SERIAL PRIMARY KEY,
    name      TEXT NOT NULL UNIQUE
);

CREATE TABLE models (
    model_id  SERIAL PRIMARY KEY,
    make_id   INT NOT NULL REFERENCES makes(make_id),
    name      TEXT NOT NULL,
    UNIQUE (make_id, name)
);

CREATE TABLE generations (
    generation_id SERIAL PRIMARY KEY,
    model_id      INT NOT NULL REFERENCES models(model_id),
    code          TEXT,            -- e.g. 'E210'
    name          TEXT,            -- e.g. '12th generation'
    year_start    INT,
    year_end      INT
);

CREATE TABLE engines (
    engine_id        SERIAL PRIMARY KEY,
    engine_code      TEXT,         -- e.g. '2ZR-FE'
    engine_name      TEXT,         -- e.g. '1.8L Dual VVT-i'
    displacement_cc  INT,
    displacement_l   NUMERIC(3,1),
    fuel_type        fuel_type,
    aspiration       TEXT,
    cylinders        INT,
    UNIQUE (engine_code, displacement_cc)
);

CREATE TABLE transmissions (
    transmission_id SERIAL PRIMARY KEY,
    name            TEXT NOT NULL,   -- 'Direct Shift-CVT', '6-speed MT'
    type            TEXT,            -- 'CVT','MT','AT','DCT'
    gears           INT
);

CREATE TABLE trims (
    trim_id   SERIAL PRIMARY KEY,
    model_id  INT NOT NULL REFERENCES models(model_id),
    name      TEXT NOT NULL
);

-- ---------- The unit record: a market-specific spec ----------
-- Specs MUST be tied to a market (US vs GCC vs JDM differ).
CREATE TABLE vehicle_specs (
    vehicle_spec_id  BIGSERIAL PRIMARY KEY,
    generation_id    INT  NOT NULL REFERENCES generations(generation_id),
    model_year       INT  NOT NULL,
    market           market_region NOT NULL,
    trim_id          INT  REFERENCES trims(trim_id),
    engine_id        INT  REFERENCES engines(engine_id),
    transmission_id  INT  REFERENCES transmissions(transmission_id),
    drivetrain       drivetrain_type,
    created_at       TIMESTAMPTZ DEFAULT now(),
    UNIQUE (generation_id, model_year, market, trim_id, engine_id, transmission_id)
);
COMMENT ON COLUMN vehicle_specs.market IS 'Every spec is market-scoped: GCC / Europe / North America / Japan / Lebanon Import.';
CREATE INDEX idx_specs_market ON vehicle_specs(market);
CREATE INDEX idx_specs_year   ON vehicle_specs(model_year);

-- ---------- FLUIDS (field-level provenance) ----------
CREATE TABLE spec_fluids (
    id              BIGSERIAL PRIMARY KEY,
    vehicle_spec_id BIGINT NOT NULL REFERENCES vehicle_specs(vehicle_spec_id) ON DELETE CASCADE,
    fluid_type      TEXT NOT NULL,    -- 'Engine Oil','Coolant','Transmission','Brake','Power Steering'
    specification   TEXT,             -- e.g. 'SAE 0W-20, API SP, ILSAC GF-6'
    capacity_value  NUMERIC(7,2),
    capacity_unit   TEXT DEFAULT 'L',
    source_id       BIGINT REFERENCES sources(source_id),
    confidence_grade confidence_grade,
    verification_status verification_status NOT NULL DEFAULT 'Not Verified',
    verification_date   DATE,
    UNIQUE (vehicle_spec_id, fluid_type)
);
CREATE INDEX idx_fluids_spec ON spec_fluids(vehicle_spec_id);

-- ---------- PERFORMANCE (field-level provenance) ----------
CREATE TABLE spec_performance (
    id              BIGSERIAL PRIMARY KEY,
    vehicle_spec_id BIGINT NOT NULL REFERENCES vehicle_specs(vehicle_spec_id) ON DELETE CASCADE,
    metric          TEXT NOT NULL,    -- 'Horsepower','Torque'
    value_numeric   NUMERIC(8,2),
    unit            TEXT,             -- 'hp','Nm','lb-ft'
    rpm             TEXT,
    source_id       BIGINT REFERENCES sources(source_id),
    confidence_grade confidence_grade,
    verification_status verification_status NOT NULL DEFAULT 'Not Verified',
    verification_date   DATE,
    UNIQUE (vehicle_spec_id, metric)
);

-- ---------- GENERIC ATTRIBUTES (tyres, battery, tank, timing, etc.) ----------
CREATE TABLE spec_attributes (
    id              BIGSERIAL PRIMARY KEY,
    vehicle_spec_id BIGINT NOT NULL REFERENCES vehicle_specs(vehicle_spec_id) ON DELETE CASCADE,
    attribute_key   TEXT NOT NULL,    -- 'fuel_tank_l','tire_sizes','battery_spec','timing_type'
    value_text      TEXT,
    value_numeric   NUMERIC(12,3),
    unit            TEXT,
    source_id       BIGINT REFERENCES sources(source_id),
    confidence_grade confidence_grade,
    verification_status verification_status NOT NULL DEFAULT 'Not Verified',
    verification_date   DATE,
    UNIQUE (vehicle_spec_id, attribute_key)
);
CREATE INDEX idx_attr_spec ON spec_attributes(vehicle_spec_id);
CREATE INDEX idx_attr_key  ON spec_attributes(attribute_key);

-- ---------- MAINTENANCE SCHEDULE (structured normal/severe) ----------
CREATE TABLE maintenance_items (
    id                   BIGSERIAL PRIMARY KEY,
    vehicle_spec_id      BIGINT NOT NULL REFERENCES vehicle_specs(vehicle_spec_id) ON DELETE CASCADE,
    item_name            TEXT NOT NULL,        -- 'Engine Oil & Filter','Spark Plugs','Coolant'...
    normal_mileage_km    INT,
    normal_time_months   INT,
    severe_mileage_km    INT,
    severe_time_months   INT,
    first_replacement_km INT,                  -- when first replacement differs (e.g. coolant)
    subsequent_interval_km INT,                -- repeat interval after first
    notes                TEXT,
    source_id            BIGINT REFERENCES sources(source_id),
    confidence_grade     confidence_grade,
    verification_status  verification_status NOT NULL DEFAULT 'Not Verified',
    verification_date    DATE,
    UNIQUE (vehicle_spec_id, item_name)
);
CREATE INDEX idx_maint_spec ON maintenance_items(vehicle_spec_id);
COMMENT ON TABLE maintenance_items IS 'Each item carries BOTH normal and severe schedules. Lebanon defaults to severe (dust/heat/stop-go).';

-- ---------- VIN DECODING ----------
-- VIN = WMI(1-3) + VDS(4-9) + VIS(10-17). char10=year, char11=plant.
CREATE TABLE vin_wmi (
    wmi             CHAR(3) PRIMARY KEY,    -- World Manufacturer Identifier
    manufacturer    TEXT,
    make_id         INT REFERENCES makes(make_id),
    country         TEXT,
    source_id       BIGINT REFERENCES sources(source_id),
    confidence_grade confidence_grade
);

CREATE TABLE vin_year_codes (              -- ISO 3779 model-year code (char 10)
    code_char   CHAR(1) PRIMARY KEY,
    model_year  INT NOT NULL
);

CREATE TABLE vin_patterns (
    id              BIGSERIAL PRIMARY KEY,
    make_id         INT REFERENCES makes(make_id),
    generation_id   INT REFERENCES generations(generation_id),
    market          market_region,
    position_start  INT,                   -- 1-based char position in VIN
    position_end    INT,
    pattern         TEXT,                  -- regex or literal e.g. 'B' / '[12]'
    identifies      TEXT,                  -- 'engine','trim','transmission','assembly_plant'
    mapped_value    TEXT,                  -- what the pattern resolves to
    source_id       BIGINT REFERENCES sources(source_id),
    confidence_grade confidence_grade,
    verification_status verification_status NOT NULL DEFAULT 'Not Verified'
);
COMMENT ON TABLE vin_patterns IS 'VDS position decoders that map VIN chars to engine/trim/transmission/plant. Populate only from verified OEM/regulatory sources.';

-- ---------- LEBANON-SPECIFIC ----------
CREATE TABLE lebanon_market_info (
    id                     BIGSERIAL PRIMARY KEY,
    vehicle_spec_id        BIGINT NOT NULL REFERENCES vehicle_specs(vehicle_spec_id) ON DELETE CASCADE,
    is_common_import       BOOLEAN,
    variant_origin         TEXT,           -- 'GCC','Europe','North America' (where Lebanon units usually come from)
    recommended_octane     TEXT,           -- e.g. '95 RON (98 acceptable)'
    maintenance_difficulty_score INT CHECK (maintenance_difficulty_score BETWEEN 1 AND 5),
    notes                  TEXT,
    source_id              BIGINT REFERENCES sources(source_id),
    confidence_grade       confidence_grade,
    verification_status    verification_status NOT NULL DEFAULT 'Not Verified',
    UNIQUE (vehicle_spec_id)
);

CREATE TABLE common_parts (
    id              BIGSERIAL PRIMARY KEY,
    vehicle_spec_id BIGINT NOT NULL REFERENCES vehicle_specs(vehicle_spec_id) ON DELETE CASCADE,
    part_category   TEXT,                  -- 'Oil Filter','Air Filter','Brake Pads','Spark Plug'
    part_name       TEXT,
    oem_part_number TEXT,
    aftermarket_refs TEXT,
    notes           TEXT,
    source_id       BIGINT REFERENCES sources(source_id),
    confidence_grade confidence_grade,
    verification_status verification_status NOT NULL DEFAULT 'Not Verified'
);
CREATE INDEX idx_parts_spec ON common_parts(vehicle_spec_id);

-- ---------- RECALLS ----------
CREATE TABLE recalls (
    id                BIGSERIAL PRIMARY KEY,
    vehicle_spec_id   BIGINT REFERENCES vehicle_specs(vehicle_spec_id) ON DELETE CASCADE,
    authority         TEXT,                -- 'NHTSA','OEM','Transport Canada'
    external_recall_id TEXT,
    description       TEXT,
    recall_date       DATE,
    remedy            TEXT,
    source_id         BIGINT REFERENCES sources(source_id),
    confidence_grade  confidence_grade,
    verification_status verification_status NOT NULL DEFAULT 'Not Verified'
);

-- ---------- Convenience view: only verified values ----------
CREATE VIEW v_verified_fluids AS
SELECT f.*, s.url, s.document_name
FROM spec_fluids f LEFT JOIN sources s ON s.source_id=f.source_id
WHERE f.verification_status='Verified';

COMMIT;
