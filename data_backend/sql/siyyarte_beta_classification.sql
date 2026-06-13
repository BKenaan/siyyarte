-- =====================================================================
-- Siyyarte — Beta dataset classification (Beta_Ready / Beta_Partial / Not_Ready)
-- Drives launch gating: only Beta_Ready vehicles surface full cards.
-- =====================================================================

-- Per-spec rollup of Grade-A verified content
CREATE OR REPLACE VIEW v_spec_rollup AS
SELECT vs.vehicle_spec_id,
  mk.name AS make, mo.name AS model, g.code AS generation, vs.model_year, vs.market,
  vs.engine_id,
  (SELECT COUNT(*) FROM spec_fluids f WHERE f.vehicle_spec_id=vs.vehicle_spec_id
     AND f.verification_status='Verified' AND f.confidence_grade='A') AS verified_fluids,
  (SELECT bool_or(f.fluid_type='Engine Oil' AND f.specification IS NOT NULL
                  AND f.verification_status='Verified' AND f.confidence_grade='A')
     FROM spec_fluids f WHERE f.vehicle_spec_id=vs.vehicle_spec_id) AS has_oil_spec,
  (SELECT bool_or(mi.verification_status='Verified' AND mi.confidence_grade='A')
     FROM maintenance_items mi WHERE mi.vehicle_spec_id=vs.vehicle_spec_id) AS has_interval,
  (SELECT bool_or(f.source_id IS NOT NULL AND f.verification_status='Verified')
     FROM spec_fluids f WHERE f.vehicle_spec_id=vs.vehicle_spec_id) AS has_cited_value
FROM vehicle_specs vs
JOIN generations g ON g.generation_id=vs.generation_id
JOIN models mo ON mo.model_id=g.model_id
JOIN makes mk ON mk.make_id=mo.make_id;

-- Beta classification
CREATE OR REPLACE VIEW v_beta_status AS
SELECT r.*,
  CASE
    WHEN r.market IS NOT NULL
         AND r.engine_id IS NOT NULL
         AND (r.has_oil_spec OR r.has_interval)
         AND r.has_cited_value
      THEN 'Beta_Ready'
    WHEN (r.verified_fluids > 0 OR r.has_interval)        -- some official Grade-A present
      THEN 'Beta_Partial'
    ELSE 'Not_Ready'
  END AS beta_status
FROM v_spec_rollup r;

-- Convenience lists (Deliverables 5/6/7)
CREATE OR REPLACE VIEW v_beta_ready   AS SELECT * FROM v_beta_status WHERE beta_status='Beta_Ready'   ORDER BY make,model,market;
CREATE OR REPLACE VIEW v_beta_partial AS SELECT * FROM v_beta_status WHERE beta_status='Beta_Partial' ORDER BY make,model,market;
CREATE OR REPLACE VIEW v_not_ready    AS SELECT * FROM v_beta_status WHERE beta_status='Not_Ready'    ORDER BY make,model,market;

-- Launch gate: a spec may surface a full card only if Beta_Ready AND qa_master_gate=0 (checked at deploy)
CREATE OR REPLACE VIEW v_launch_summary AS
SELECT beta_status, COUNT(*) AS specs, COUNT(DISTINCT make||'|'||model) AS distinct_models
FROM v_beta_status GROUP BY beta_status ORDER BY 1;
