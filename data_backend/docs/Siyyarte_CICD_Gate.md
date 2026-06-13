# Siyyarte — CI/CD QA Deployment Gate

## Pipeline position
`build → migrate(to staging) → **QA GATE** → manual approve → deploy(prod)`

## Gate (siyyarte_cicd_qa_gate.sh)
1. Runs `qa_master_gate` (12 rules). **Block deploy if SUM(n) != 0.**
2. On failure: export `qa_failures_<date>.csv` + per-rule detail CSVs (failed-QA export format).
3. Require **manual approval** before any retry (no auto-retry).
4. On pass: print `v_launch_summary` and approve.

## Failed-QA export format
`rule, <table>, id, <offending columns>` per CSV. Master summary: `rule,n`.

## Rollback plan
1. Releases are immutable, versioned (`beta_dataset_v0_1`, `v0_2`, …). Prod points at a version tag.
2. Each migration wrapped in a transaction; failure → automatic `ROLLBACK`, prod unchanged.
3. Bad release detected post-deploy → repoint prod to previous version tag (DB snapshot/restore of the prior tagged dataset).
4. Any record that triggered the issue is logged to `qa_findings` (status OPEN) and **downgraded** (verification_status→Not Verified) so it stops rendering — data preserved, not deleted (same protocol as the Tucson case).
5. Post-mortem appended to the QA report; re-deploy only after gate returns 0.

## Trust invariant
No deploy ever ships a value that isn't Verified_A + grade A + cited + market-scoped. The gate makes this mechanical, not manual.
