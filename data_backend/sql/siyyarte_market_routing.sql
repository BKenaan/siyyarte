-- =====================================================================
-- Siyyarte — Market-Routing model for Lebanon's mixed-import fleet
-- Resolves a physical Lebanese vehicle to its SOURCE-MARKET spec record.
-- Output contract: likely_market, confidence_score, required_user_confirmation_fields, matching_vehicle_records.
-- =====================================================================
BEGIN;

CREATE TABLE market_routing_clues (
    clue_id        TEXT PRIMARY KEY,
    clue_name      TEXT NOT NULL,
    how_observed   TEXT,             -- VIN / user input / photo / dropdown
    points_to      market_region,    -- market this clue indicates
    signal         TEXT,             -- the observed value -> market
    weight         NUMERIC(3,2),     -- 0..1 contribution to confidence
    is_decisive    BOOLEAN DEFAULT FALSE,  -- alone enough to route
    notes          TEXT
);

INSERT INTO market_routing_clues VALUES
('VIN_WMI','VIN World Manufacturer Identifier','VIN chars 1-3','North America','VIN pos1 in {1,4,5}=USA, 2=Canada, 3=Mexico',0.45,FALSE,'Indicates ASSEMBLY plant, not always sale market; strong for US trucks/SUVs'),
('VIN_WMI_JP','VIN WMI (Japan)','VIN chars 1-3','Japan','VIN pos1=J',0.40,FALSE,'JDM/Japan-export'),
('VIN_WMI_KR','VIN WMI (Korea)','VIN chars 1-3','GCC','VIN pos1=K (Korea-built; often GCC-export)',0.25,FALSE,'Korea-built can be GCC or other; weak alone'),
('VIN_WMI_DE','VIN WMI (Germany)','VIN chars 1-3','Europe','VIN pos1=W',0.35,FALSE,'German-built; could be US or EU sale'),
('ODO_UNIT','Odometer unit','User dropdown / cluster photo','North America','miles (mph primary)',0.40,FALSE,'Miles cluster ~ US-spec; km ~ GCC/EU/JP'),
('ODO_UNIT_KM','Odometer unit km','User dropdown','GCC','kilometres (km/h primary)',0.20,FALSE,'km is GCC/EU/JP (not decisive)'),
('FUEL_OCTANE_LABEL','Fuel-cap / manual octane unit','Photo / manual','North America','AKI (R+M)/2 numbers (87/91)',0.35,FALSE,'AKI labeling = US; RON (95/98) = GCC/EU'),
('OCTANE_RON','Octane RON label','Photo / manual','GCC','RON (95/98)',0.25,FALSE,'RON = GCC/EU/JP'),
('REAR_FOG','Rear fog light present','Photo / user','Europe','present',0.20,FALSE,'EU mandates rear fog; US often omits'),
('GCC_HEAT_PKG','GCC heat/cooling package badge','Spec / dealer','GCC','heavy-duty cooling / GCC spec badge',0.30,FALSE,'GCC heat package indicates Gulf spec'),
('EMISSIONS_LABEL','Underhood emissions label region','Photo','North America','EPA/CARB label',0.40,FALSE,'EPA label = US; GCC/EU have own'),
('MANUAL_REGION','Glovebox owner-manual region','Photo / user','North America','en_US manual / "United States and Canada"',0.40,FALSE,'Manual region strongly implies sale market'),
('ENGINE_AVAIL','Engine availability by market','Selected engine','North America','engine offered only in that market (e.g. 6.2L L87, PowerStroke)',0.50,TRUE,'If engine exists ONLY in one market, decisive'),
('TRIM_NAMING','Trim naming difference','Selected trim','North America','US-only trim name (e.g. High Country, King Ranch)',0.35,FALSE,'US-only trims indicate US-spec'),
('IMPORT_HISTORY','User-stated import origin','User input','North America','user says "imported from USA"',0.55,TRUE,'User-provided origin is decisive if given');

-- View: distinct source markets we hold a record for, per model (drives confirmation prompt)
CREATE VIEW v_market_options AS
SELECT mo.name AS model, array_agg(DISTINCT vs.market::text ORDER BY vs.market::text) AS markets_available
FROM vehicle_specs vs
JOIN generations g ON g.generation_id=vs.generation_id
JOIN models mo ON mo.model_id=g.model_id
GROUP BY mo.name;
COMMENT ON VIEW v_market_options IS 'If a model has >1 market record, routing MUST disambiguate (clues or user confirmation) before serving specs.';

COMMIT;
