# Siyyarte Beta v0.1 — QA Report

## Gate result
`qa_master_gate` = **0 violations expected** across all 12 rules at release (asserted by `beta_dataset_v0_1.sql`).

| Rule | Check | Enforced by |
|------|-------|-------------|
| QA1 | Verified value has source_id | trigger + view |
| QA2 | source has page/section | trigger + view |
| QA3 | record has market_scope | NOT NULL + view |
| QA4 | no duplicate vehicle-engine-market | unique index |
| QA5 | no source across >1 market | view |
| QA6 | not Verified if blocked | view |
| QA7 | no ICE fields on EV | view |
| QA8 | interval has a unit | view |
| QA9 | capacity has a unit | view |
| QA10 | tyre has market context | view |
| QA11 | local file has SHA-256 | view + source_archive |
| QA12 | no non-en_GN Hyundai / EU source for GCC | view |

## Findings log (qa_findings)
| ID | Vehicle | Issue | Status |
|----|---------|-------|--------|
| 1 | Hyundai Tucson GCC | source possibly EU | **RESOLVED** (en_GN=Gulf Nations; ME oil grade proof; restored) |
| 2 | Hyundai/Kia market-source | label vs region | **RESOLVED** (en_GN + ME rows accepted; QA12 enforces) |
| 3 | MG lineup | RX5/MG6 → RX9/MG7 | OPEN (correct on extraction) |
| 4 | BYD/MG/GAC caps | sandbox download block | OPEN (access fix needed) |
| 5 | US/GCC American | merge risk | MITIGATED (QA5) |

## Integrity posture
Every rendered value: Verified_A + grade A + source_id + page citation + market_scope. Blocked/missing values render as status. Two HIGH/MED findings resolved by evidence; the Tucson case demonstrates the downgrade-investigate-restore protocol working.
