# Siyyarte Beta Dataset v0.1 — Release Manifest

**Release:** Siyyarte Beta Dataset v0.1 · **Date:** 2026-06-13 · **Status:** Beta-launch-safe (not coverage-complete)

## Contents
| Component | File |
|-----------|------|
| Master load order | `beta_dataset_v0_1.sql` |
| Schema + ENUMs | `siyyarte_schema.sql` |
| Source registry (+ext/updates) | `siyyarte_source_registry*.sql`, `siyyarte_registry_update_phase*.sql` |
| Canonical P1 + sweep + pilots + GM/Ford + Korean + American | `siyyarte_P1_canonical_gradeA.sql`, `siyyarte_sweep_gradeA.sql`, `siyyarte_phase2_pilots.sql`, `siyyarte_phase3_gmford.sql`, `siyyarte_phase6_korean.sql`, `siyyarte_phase7_american.sql` |
| Market routing | `siyyarte_market_routing.sql` |
| Operating conditions (Lebanon severe) | `siyyarte_operating_conditions.sql` |
| QA gates + findings + archive | `siyyarte_qa_gates.sql`, `siyyarte_phase5_integrity.sql`, `siyyarte_phase5_hyundai_reconcile.sql` |
| Beta classification | `siyyarte_beta_classification.sql` |
| Field-level export | `beta_field_level_export.xlsx` |
| QA report | `beta_qa_report.md` |
| Routing rules / display states / API / CI | `Siyyarte_Market_Routing_Model.md`, `Siyyarte_Display_State_Test_Cases.md`, `Siyyarte_Backend_API_Plan.md`, `Siyyarte_CICD_Gate.md` |

## Beta contents (snapshot)
- **Beta_Ready:** ~37 specs / ~34 models (Toyota Corolla/Land Cruiser, Mazda CX-5, Isuzu D-Max, Hyundai Tucson/Elantra/Santa Fe/Sonata/Kona/Palisade, Kia Picanto/Sportage/Cerato/Sorento/K5/Seltos/Telluride/Pegas/Rio, GM Tahoe/Suburban/Silverado/Equinox/Traverse + GMC Yukon/Sierra/Terrain/Acadia + Cadillac Escalade, Ford Explorer/F-150/Expedition/Edge/Escape/Mustang, GAC Emzoom/Emkoo).
- **Beta_Partial:** Nissan Patrol, Mitsubishi L200 (engine/identity only).
- **Not_Ready:** Hilux, Prado, BYD/MG (official source located, Blocked_OCR).

## Markets
GCC (Hyundai/Kia/Toyota/Mazda/Isuzu/GAC) and North America (GM/Ford/Cadillac — US-spec) are **separate records**. Never merged. `Lebanon Import` resolved at runtime by the market-routing model.

## Release gate
`beta_dataset_v0_1.sql` ends by asserting `qa_master_gate = 0` → prints `RELEASE OK` / `RELEASE BLOCKED`. CI uses `siyyarte_cicd_qa_gate.sh`.

## Known limitations (honest)
- BYD/MG/GAC capacities, Hyundai small cars (Accent/Creta/i10/i20), German VIN-gated capacities, Honda/Land Rover (login), GMC Terrain/Acadia intervals → **official source located but Blocked** (OCR/Login/access). Shown as status, never as numbers.
- US-spec American records present; GCC-spec American not publicly sourced (no merge).
