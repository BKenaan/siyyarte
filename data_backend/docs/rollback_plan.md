# Siyyarte — Rollback Plan (Beta v0.1)

## Principles
- Releases are **immutable + versioned** in `release_versions`. Production points at one version tag.
- Every migration runs in a transaction → on error, automatic `ROLLBACK`, production untouched.

## Triggers for rollback
- `qa_master_gate != 0` post-migration · a confirmed wrong value reaches users · API emits an unverified number (should be impossible — defence in depth).

## Procedure
1. Repoint production to the previous version tag (restore the prior tagged dataset snapshot).
2. Open a `qa_findings` row (status OPEN) for the offending record.
3. **Downgrade, don't delete:** set the record's `verification_status='Not Verified'` so it stops rendering; data preserved for re-verification (the Tucson protocol).
4. Re-run `siyyarte_cicd_qa_gate.sh`; only re-deploy when it returns 0.
5. Append post-mortem to `beta_qa_report.md`.

## Time-to-restore target
< 15 min (tag repoint). No user ever sees a value that failed the gate.
