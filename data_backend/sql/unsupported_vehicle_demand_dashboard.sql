-- =====================================================================
-- Siyyarte — Unsupported-vehicle demand engine (Phase 8)
-- Turns the capture flow into the next-extraction priority signal.
-- =====================================================================
BEGIN;

-- Per-request issue typing (extends unsupported_vehicle_requests)
ALTER TABLE unsupported_vehicle_requests ADD COLUMN IF NOT EXISTS issue_type TEXT;  -- 'not_listed','partial','wrong_value','market_unknown'
ALTER TABLE unsupported_vehicle_requests ADD COLUMN IF NOT EXISTS missing_field TEXT; -- field the user wanted

-- Demand rankings
CREATE OR REPLACE VIEW v_demand_brands AS
  SELECT brand, COUNT(*) requests FROM unsupported_vehicle_requests GROUP BY brand ORDER BY requests DESC;
CREATE OR REPLACE VIEW v_demand_models AS
  SELECT brand, model, COUNT(*) requests FROM unsupported_vehicle_requests GROUP BY brand,model ORDER BY requests DESC;
CREATE OR REPLACE VIEW v_demand_fields AS
  SELECT missing_field, COUNT(*) requests FROM unsupported_vehicle_requests
  WHERE missing_field IS NOT NULL GROUP BY missing_field ORDER BY requests DESC;
CREATE OR REPLACE VIEW v_market_uncertainty AS
  SELECT COUNT(*) FILTER (WHERE market_origin IS NULL OR market_origin='unknown') AS unknown_market,
         COUNT(*) AS total,
         ROUND(100.0*COUNT(*) FILTER (WHERE market_origin IS NULL OR market_origin='unknown')/NULLIF(COUNT(*),0),1) AS pct_unknown
  FROM unsupported_vehicle_requests;
CREATE OR REPLACE VIEW v_vin_submission_rate AS
  SELECT COUNT(*) FILTER (WHERE vin_hash IS NOT NULL) AS with_vin,
         COUNT(*) FILTER (WHERE vin_hash IS NULL)     AS without_vin,
         COUNT(*) AS total FROM unsupported_vehicle_requests;

-- Next-extraction priority (Workstream G scoring, computed from REAL demand)
-- Priority = demand_requests * fleet_relevance_weight * source_availability_weight * maintenance_importance_weight
CREATE TABLE IF NOT EXISTS extraction_scoring_weights (
    brand TEXT, model TEXT,
    fleet_relevance NUMERIC,        -- 1..5 from Lebanese Priority Index
    source_availability NUMERIC,    -- 1.0 fetchable / 0.6 OCR-login / 0.2 not found
    maintenance_importance NUMERIC, -- 1..3
    PRIMARY KEY (brand,model)
);
CREATE OR REPLACE VIEW v_next_extraction_priority AS
  SELECT d.brand, d.model, d.requests,
         COALESCE(w.fleet_relevance,3) fleet,
         COALESCE(w.source_availability,0.6) src,
         COALESCE(w.maintenance_importance,2) maint,
         ROUND(d.requests * COALESCE(w.fleet_relevance,3) * COALESCE(w.source_availability,0.6) * COALESCE(w.maintenance_importance,2),1) AS priority_score
  FROM v_demand_models d
  LEFT JOIN extraction_scoring_weights w ON w.brand=d.brand AND w.model=d.model
  ORDER BY priority_score DESC;
COMMENT ON VIEW v_next_extraction_priority IS 'Phase 9 queue: ranks what to extract next by REAL beta demand x fleet x source x maintenance importance.';

COMMIT;
