-- Siyyarte — Beta feedback analysis (Phase 9, Workstream G)
CREATE OR REPLACE VIEW v_feedback_summary AS
SELECT COUNT(*) responses,
  ROUND(100.0*COUNT(*) FILTER (WHERE vehicle_found)/NULLIF(COUNT(*),0),1) pct_vehicle_found,
  ROUND(100.0*COUNT(*) FILTER (WHERE market_correct)/NULLIF(COUNT(*),0),1) pct_market_correct,
  ROUND(100.0*COUNT(*) FILTER (WHERE reminders_useful)/NULLIF(COUNT(*),0),1) pct_reminders_useful,
  ROUND(100.0*COUNT(*) FILTER (WHERE trusted_citation)/NULLIF(COUNT(*),0),1) pct_trusted_citation
FROM beta_feedback;
CREATE OR REPLACE VIEW v_top_missing_info AS
SELECT info_missing, COUNT(*) n FROM beta_feedback WHERE info_missing IS NOT NULL GROUP BY 1 ORDER BY n DESC;
CREATE OR REPLACE VIEW v_top_friction AS
SELECT confusing, COUNT(*) n FROM beta_feedback WHERE confusing IS NOT NULL GROUP BY 1 ORDER BY n DESC;
-- "live" next-extraction priority (alias over the demand engine for Phase 9 naming)
CREATE OR REPLACE VIEW v_live_next_extraction_priority AS SELECT * FROM v_next_extraction_priority;
