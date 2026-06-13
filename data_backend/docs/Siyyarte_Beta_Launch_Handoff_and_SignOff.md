# Siyyarte Beta Launch Handoff & Sign-Off

**Prepared for:** Development, Operations, and Product teams
**Date:** 2026-06-13 · **Release:** Beta Dataset v0.1 · **Status:** **Pre-launch ready**

> One-line summary: *Siyyarte is pre-launch ready. Phase 10 becomes measurable only after real deployment and real beta usage. This document contains no simulated metrics, users, demand, or feedback — those exist only after launch.*

---

## 1. Current Project Status

### Fully built and validated
- **Data model:** normalized PostgreSQL schema with field-level provenance, market scoping, and an A/B/C/D confidence scale + 5-level verification framework (Verified_A / Verified_B / Blocked_OCR / Blocked_Login / Unavailable). All SQL parse-validated (libpg_query + plpgsql).
- **Grade-A dataset:** official-source-only, field-cited, market-scoped records across **GCC** (Toyota, Lexus, Hyundai, Kia, Mazda, Isuzu, GAC) and **North America / US-spec** (Chevrolet, GMC, Cadillac, Ford). ~300 Grade-A field-values; **zero B/C/D in production rows**.
- **Integrity enforcement (triple-layered):** (1) `qa_master_gate` — 12 QA rules as triggers/constraints/views; (2) Verified-A-only API read model (server cannot emit an unverified number); (3) `<SpecValue>` frontend contract (UI cannot render one).
- **Market routing:** weighted clue model + confirmation flow (asks the user when confidence < 0.7; never auto-guesses US vs GCC).
- **Source registry + archive:** reusable pipeline catalogue; `source_archive` with SHA-256 + page-count for source-drift protection; ingestion tool proven end-to-end.
- **Operational instruments:** beta metrics views, feedback dashboard, unsupported-vehicle capture (VIN hashed only), live demand ranking, downgrade-first data-issue triage, CI/CD QA gate, rollback plan.

### Beta-launch-ready
- **Beta_Ready (~34 models):** render full verified values.
- **Beta_Partial (e.g., Patrol, L200):** shown honestly (verified fields + labelled gaps).
- **Not_Ready / Blocked / Unavailable:** shown as status, captured via request flow — never numbers.

### Still requires real-world execution
- App deployment to a real environment.
- Recruiting and onboarding 25–50 real beta users.
- Real usage, real unsupported-vehicle requests, real feedback.
- The Chinese/EV infrastructure allowlist (egress access).

---

## 2. Pre-Launch Go / No-Go Checklist
Launch only if **all** are GREEN:
- [ ] `SELECT SUM(n) FROM qa_master_gate` = **0**
- [ ] Beta Dataset v0.1 loaded (`beta_dataset_v0_1.sql`, prints `RELEASE OK`)
- [ ] Verified-A-only API view active (no endpoint returns a number without source + page + grade A + Verified)
- [ ] Frontend display-state system active (7 states; no blank/0/N-A as data)
- [ ] Unsupported-vehicle capture active (writes to `unsupported_vehicle_requests`)
- [ ] Market-routing confirmation active (prompts when confidence < 0.7)
- [ ] VIN hashing confirmed (SHA-256 only; raw VIN never stored)
- [ ] Rollback plan ready (previous version tag retained; downgrade-first available)
- [ ] Release notes attached to deployment

**Go/No-Go rule:** GO only with gate = 0 **and** API smoke pass **and** rollback staged.

---

## 3. Phase-10 Deliverable Mapping

| Phase-10 deliverable | Classification |
|----------------------|----------------|
| QA gate / Verified-A view / display states / routing / capture / triage / rollback | **Already built** |
| Daily metrics, coverage report, trust report, feedback dashboard, citation views | **Ready to capture once live** (instruments built; need real events) |
| Go-live report (actuals), Day-1 / Day-3 / Day-7 reports, 7-day KPI dashboard | **Requires real beta users** |
| Live extraction priority report, Beta v0.2 candidate list (demand-led) | **Requires real beta users** (depends on real `unsupported_vehicle_requests`) |
| Beta feedback summary, friction points, feature requests, retention risk | **Requires real beta users** |
| BYD Atto 3 retest result, Chinese/EV extraction | **Requires infrastructure unblock** (egress allowlist) |

---

## 4. Real Beta Execution Runbook (for Dev/Ops)

### Launch to 25–50 users
1. Provision production DB; run `beta_dataset_v0_1.sql`; confirm `RELEASE OK`.
2. Deploy backend (Verified-A API view) + frontend (7 display states); run `siyyarte_cicd_qa_gate.sh` — deploy only on gate = 0.
3. Recruit a deliberately mixed cohort: GCC-spec, US-import, Korean economy, American SUVs/trucks, plus deliberately Partial and Not_Ready owners (so capture + status states get exercised).
4. Record actuals into `beta_go_live_report.md` and `release_versions` (`promoted_to='production'`).

### Monitor daily
- `SELECT * FROM beta_daily_metrics;` (users, registrations, Ready/Partial/Not_Ready %, market-confirmed vs unknown).
- `SELECT * FROM v_demand_models;` and `v_market_uncertainty`, `v_vin_submission_rate`.
- `SELECT * FROM beta_most_blocked_fields;` and `beta_top_citations;`.
- `qa_findings` for any user-reported issue.

### Day 1 / Day 3 / Day 7 reports
- Use the runbooks `beta_user_coverage_report.md` and `beta_trust_metrics_report.md`; fill the metric columns from the views above — **with real numbers only**.
- Day 7: snapshot `beta_7_day_kpi_dashboard` (build from `beta_daily_metrics` + `v_feedback_summary`).

### Using `v_live_next_extraction_priority` (after real requests exist)
- `SELECT * FROM v_live_next_extraction_priority LIMIT 15;` → demand-ranked candidates.
- Cross-check `source_registry.status`; pick top-N with an OPEN pipeline; record the decision in `weekly_extraction_decision_report.md`. **Never pick manually; never rank on requests that weren't made.**

---

## 5. Data Integrity Rules for Launch (non-negotiable)
1. **No unverified values rendered** — a number appears only if `verification_status='Verified' AND confidence_grade='A'`.
2. **No fake user metrics** — every KPI comes from a real query over real events.
3. **No simulated demand** — the extraction queue ranks only real `unsupported_vehicle_requests`.
4. **No invented feedback** — feedback comes only from real submissions.
5. **Downgrade-first for reported issues** — flag Under_Review → remove from render → preserve original in `value_history` → re-check official source → restore only if confirmed. Never silently overwrite.
6. **VIN privacy** — SHA-256 only; raw VIN never stored or displayed.

---

## 6. Chinese / EV Blocker Status
- **BYD, MG, GAC remain Blocked_Access.** Official Grade-A sources are located and registered; their deep spec pages are unreachable due to the sandbox/egress restriction (allowlist + binary-fetch). **No values fabricated.**
- **Gate:** the **BYD Atto 3 acceptance test** (9 steps) must pass after `infra_ticket_chinese_pdf_access.md` is completed (allowlist `byd.com`, `media-hub-prod.mgmotor.me`, `gacmotorsaudi.com`, or mount the PDFs).
- **Until then:** keep these models in demand reports (ranked, not extracted). If the test passes, they enter the live extraction queue; if it fails, they stay Blocked_Access — still no fabricated values.

---

## 7. Final Recommendation
1. **Launch the controlled beta only when the real app environment is ready** — deployed backend, frontend, and production DB with the gate enforced.
2. **Let real unsupported requests choose Beta v0.2** — define v0.2 scope from `v_live_next_extraction_priority`, not assumptions, and admit a record only if it passes official-source + market-scope + field-citation + Verified_A + gate = 0.
3. **Do not expand before beta data exists.** The highest-value next move is real usage, which converts guesses into measurements.
4. **Close the infra ticket** to unlock the single biggest pending segment (Chinese/EV) cleanly.

---

## 8. Ownership & Accountability

| Function | Owner (name) | Responsibility | Sign |
|----------|--------------|----------------|------|
| **Development** | __________________ | Deploy backend + Verified-A-only API view; run CI/CD QA gate; wire display states; implement VIN hashing | ______ |
| **Operations / Infra** | __________________ | Provision prod DB; load v0.1; confirm gate = 0; staged rollback; complete Chinese/EV egress allowlist ticket | ______ |
| **Product** | __________________ | Recruit 25–50 mixed beta cohort; own day-1/3/7 reporting; triage user-reported issues (downgrade-first); define v0.2 from real demand | ______ |
| **Data / QA (steward)** | __________________ | Guard the integrity rules; approve any restore of a downgraded record; nightly `qa_master_gate` audit | ______ |

---

## 9. GO / NO-GO Decision Record

Record the decision **at deployment time** against real checks. Do not pre-fill with assumed values.

| Gate item | Required | Verified? (Y/N) | Evidence / note |
|-----------|----------|-----------------|-----------------|
| `qa_master_gate` = 0 | Yes | __ | query output |
| Beta Dataset v0.1 loaded (`RELEASE OK`) | Yes | __ | load log |
| Verified-A-only API view active | Yes | __ | API smoke run |
| Frontend display states active (7) | Yes | __ | UI review |
| Unsupported-vehicle capture active | Yes | __ | test submission |
| Market-routing confirmation active | Yes | __ | low-confidence test |
| VIN hashing confirmed (no raw VIN) | Yes | __ | code + DB check |
| Rollback staged (prev tag retained) | Yes | __ | release_versions |
| Release notes attached | Yes | __ | deployment record |

**Decision:** ☐ GO  ☐ NO-GO
**Condition:** GO only if every row above is Y.
**Decided by:** __________ (Dev) · __________ (Ops) · __________ (Product) · __________ (Data/QA)
**Date / Release tag:** __________ / `beta_dataset_v0_1`

---

## 10. Known Risks (at hand-off)

| # | Risk | Impact | Status / Mitigation |
|---|------|--------|---------------------|
| R1 | **Chinese/EV access blocked** — BYD/MG/GAC official PDFs unreachable (egress allowlist / binary-fetch) | No EV or Chinese-brand verified coverage at launch | Open infra ticket; BYD Atto 3 acceptance test is the gate; models stay **Blocked_Access**, ranked in demand, **never fabricated** |
| R2 | **No live beta data yet** — all coverage/trust/demand KPIs are unmeasured until launch | Phase-10 outcomes cannot be evaluated pre-launch | Instruments built and ready; measurement begins only with real users — **no simulated metrics** |
| R3 | **Dependency on real deployment** — backend/frontend/prod-DB must be stood up by dev/ops | Launch cannot proceed until environment exists | Runbook (§4) + go/no-go (§9) provided; gate enforced at deploy |
| R4 | **Market-label drift** (US-import vs GCC of same nameplate) | Wrong-market value risk | Mitigated: market-scoped records + routing confirmation (<0.7 asks user) + QA5/QA12; never merge markets |
| R5 | **Source drift** (OEM removes/changes a PDF) | Citation could break post-launch | `source_archive` (SHA-256 + local copy) preserves cited documents |
| R6 | **Partial-coverage perception** — users may see many "pending" fields | Possible disappointment | Honest by design; capture flow turns gaps into demand; copy explains "not verified yet" |

---

## Sign-Off

**Siyyarte is pre-launch ready.** The dataset is official, market-scoped, field-cited, and QA-gated; the integrity guarantees are enforced in three independent layers; the operational instruments to measure a real beta are in place.

**Phase 10 becomes measurable only after real deployment and real beta usage.** No metrics, users, demand, or feedback in this project have been simulated. The next true milestone is a live controlled beta — executed by the dev/ops team — producing the first real data.

*Prepared with the project's governing rule intact: Siyyarte may say "not verified yet"; it must never show an unverified number — and that includes never showing an unverified metric.*
