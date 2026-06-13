-- =====================================================================
-- Siyyarte — Beta operations schema + daily metrics (Phase 9)
-- Privacy: user + VIN stored as SHA-256 only. No raw PII.
-- =====================================================================
BEGIN;

CREATE TABLE IF NOT EXISTS beta_registrations (
    registration_id   BIGSERIAL PRIMARY KEY,
    user_id_hash      CHAR(64) NOT NULL,           -- hashed user id
    vehicle_spec_id   BIGINT REFERENCES vehicle_specs(vehicle_spec_id), -- NULL if unsupported
    matched_beta_status TEXT,                       -- Beta_Ready/Partial/Not_Ready/Unsupported
    market_confirmed  market_region,
    market_confidence NUMERIC(3,2),
    vin_hash          CHAR(64),                     -- never raw VIN
    created_at        TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_reg_day ON beta_registrations((created_at::date));

CREATE TABLE IF NOT EXISTS beta_feedback (
    feedback_id     BIGSERIAL PRIMARY KEY,
    registration_id BIGINT REFERENCES beta_registrations(registration_id),
    vehicle_found   BOOLEAN,
    market_correct  BOOLEAN,
    reminders_useful BOOLEAN,
    info_missing    TEXT,
    trusted_citation BOOLEAN,
    confusing       TEXT,
    created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS citation_view_events (
    id BIGSERIAL PRIMARY KEY, vehicle_spec_id BIGINT, source_id BIGINT,
    viewed_at TIMESTAMPTZ DEFAULT now()
);

-- Daily metrics (Workstream B / Deliverable 3)
CREATE OR REPLACE VIEW beta_daily_metrics AS
SELECT created_at::date AS day,
  COUNT(*) AS registrations,
  COUNT(DISTINCT user_id_hash) AS users,
  COUNT(*) FILTER (WHERE matched_beta_status='Beta_Ready')  AS matched_ready,
  COUNT(*) FILTER (WHERE matched_beta_status='Beta_Partial') AS matched_partial,
  COUNT(*) FILTER (WHERE matched_beta_status IN ('Not_Ready','Unsupported')) AS not_ready,
  ROUND(100.0*COUNT(*) FILTER (WHERE matched_beta_status='Beta_Ready')/NULLIF(COUNT(*),0),1) AS pct_ready,
  COUNT(*) FILTER (WHERE market_confirmed IS NOT NULL) AS market_confirmed_cnt,
  COUNT(*) FILTER (WHERE market_confirmed IS NULL)     AS unknown_market_cnt
FROM beta_registrations GROUP BY 1 ORDER BY 1 DESC;

-- Most-blocked fields surfaced to users (Beta_Partial Not-Verified renders)
CREATE OR REPLACE VIEW beta_most_blocked_fields AS
SELECT f.fluid_type AS field, COUNT(*) AS blocked_instances
FROM spec_fluids f WHERE f.verification_status='Not Verified'
GROUP BY f.fluid_type ORDER BY blocked_instances DESC;

-- Most-viewed source citations (trust signal)
CREATE OR REPLACE VIEW beta_top_citations AS
SELECT s.document_name, COUNT(*) views
FROM citation_view_events e JOIN sources s ON s.source_id=e.source_id
GROUP BY s.document_name ORDER BY views DESC;

COMMIT;
