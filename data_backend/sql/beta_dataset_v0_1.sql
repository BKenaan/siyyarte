-- =====================================================================
-- SIYYARTE BETA DATASET v0.1 — master load order
-- Run top-to-bottom on a fresh PostgreSQL DB. Final step asserts qa_master_gate=0.
-- DEPRECATED (do NOT load — superseded by canonical): siyyarte_corolla_seed.sql,
--   siyyarte_corolla_NA_gradeA_seed.sql, siyyarte_gcc_corolla_*.sql,
--   siyyarte_landcruiser_*.sql, siyyarte_l200_gcc_gradeA.sql
-- =====================================================================
\i siyyarte_schema.sql                    -- core schema + ENUMs
\i siyyarte_source_registry.sql           -- source_registry + verification_level
\i siyyarte_source_registry_ext.sql
\i siyyarte_registry_update_phase2.sql
\i siyyarte_registry_update_phase3.sql
\i siyyarte_registry_update_phase4.sql
\i siyyarte_P1_canonical_gradeA.sql        -- canonical P1 (Corolla GCC+NA, LandCruiser, L200, Hilux)
\i siyyarte_sweep_gradeA.sql               -- Mazda CX-5, Isuzu D-Max, Tucson, Picanto, Patrol Y63
\i siyyarte_phase2_pilots.sql              -- Tahoe, Yukon, Explorer, F-150 (US) + Kia + GAC
\i siyyarte_phase3_gmford.sql              -- Suburban, Escalade, Expedition, Silverado, Sierra, Edge (US)
\i siyyarte_phase6_korean.sql              -- Kona, Palisade, K5, Seltos, Telluride, Pegas, Rio (GCC)
\i siyyarte_phase7_american.sql            -- Equinox, Traverse, Terrain, Acadia, Escape, Mustang (US) + capture flow
\i siyyarte_market_routing.sql             -- market_routing_clues + v_market_options
\i siyyarte_operating_conditions.sql       -- Lebanon severe-service profile
\i siyyarte_qa_gates.sql                   -- 10 base QA rules + triggers + master gate
\i siyyarte_phase5_integrity.sql           -- qa_findings, source_archive, Tucson downgrade, QA11/12
\i siyyarte_phase5_hyundai_reconcile.sql   -- Tucson RESTORED + Elantra/SantaFe/Sonata (GCC) + finding resolved
\i siyyarte_beta_classification.sql        -- v_beta_status / v_beta_ready / v_beta_partial / v_not_ready
-- RELEASE GATE: must print zero violations
\echo '== qa_master_gate (all rows must be 0) =='
SELECT * FROM qa_master_gate;
SELECT CASE WHEN (SELECT SUM(n) FROM qa_master_gate)=0 THEN 'RELEASE OK' ELSE 'RELEASE BLOCKED' END AS gate;
