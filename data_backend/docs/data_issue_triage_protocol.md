# Siyyarte — Data-Issue Triage Protocol (downgrade-first)

**Never silently overwrite a production value.**

## Flow (when a user reports a possible wrong value)
1. **Flag Under_Review** — call `flag_fluid_under_review(field_id, reason, vehicle)`. This:
   - copies the current value to `value_history` (step 3 — preserve original),
   - sets `verification_status='Not Verified'` (step 2 — removed from renderable Verified_A),
   - opens a `qa_findings` row, status `UNDER_REVIEW` (step 4).
2. **Re-check the official source** (step 5) — re-open the cited document + page.
3. **Resolve:**
   - Confirmed correct → `restore_fluid(field_id, finding_id)` (step 6: restore Verified_A; finding RESOLVED).
   - Not confirmed → keep `Not Verified`; set finding `RESOLVED` with note "downgraded to Verification_Pending/Blocked" (step 7).
4. Append to `corrected_records_log.md`.

## SLA
Acknowledge < 24h; resolve < 48h. While Under_Review, the field shows "Verification pending" — never the disputed number.

## Guarantee
The disputed value is **never shown** between flag and resolution, and the original is **never lost** (`value_history`).
