# Data-fix ticket — Phase 3 GM/Ford models excluded from production

**Status:** OPEN — blocking these models from production
**Severity:** High (silent data loss; file fails the QA gate on clean PostgreSQL 16)
**Component:** `data_backend/sql/siyyarte_phase3_gmford.sql`
**Filed:** 2026-06-13
**Found during:** verified-specs ingest into Firestore (`build_and_export.sh` faithful load + `qa_master_gate` assertion)

## Summary
`siyyarte_phase3_gmford.sql` does **not load** on a clean PostgreSQL 16 instance and is therefore **excluded from the production dataset**. None of its vehicles reached Firestore. They must stay excluded until repaired through official, page-cited sources — per the dataset golden rule (*never display an unverified value*).

## Affected vehicles (all currently MISSING from production)
- Cadillac **Escalade** (T1XX) — engines L87, LT4
- Chevrolet **Suburban** (T1XX) — engines L84, L87
- Chevrolet **Silverado 1500** (T1XX) — engines L3B, L84, L87
- GMC **Sierra 1500** (T1XX) — engines L3B, L84, L87
- Ford **Expedition** (U553) — engine 3.5 EcoBoost
- Ford **Edge** (CD539) — engines 2.0 EcoBoost, 2.7 EcoBoost

> Note: Tahoe, Yukon, Explorer and F-150 come from **phase2_pilots** (loaded OK) and are NOT affected by this ticket.

## Root causes (two distinct defects)

### 1. Missing source documents (primary blocker)
The DO block resolves each row's citation with:
```sql
src := (SELECT source_id FROM sources WHERE document_name LIKE rec.srclike);
```
The patterns it looks for return **zero rows** — those source documents were never inserted into the `sources` table:
- `2023 Cadillac Escalade%`
- `2024 Chevrolet Silverado%`
- `2023 GMC Sierra%`
- `2022 Ford Expedition%`
- `2022 Ford Edge%`

With `src = NULL`, every `spec_fluids` / `maintenance_items` row is inserted as `verification_status='Verified'` but `source_id IS NULL`, which the QA trigger `qa_verified_requires_source()` rejects (QA1), and `qa_master_gate` would flag (QA1/QA2) even if the trigger were absent.

### 2. Multi-row scalar subquery (secondary)
```sql
(SELECT g.generation_id FROM generations g JOIN models m ON m.model_id=g.model_id
 WHERE m.name=rec.model AND g.code=rec.gcode)
```
A `T1XX` generation is created **twice**, so for the GM models this scalar subquery can return >1 row → `ERROR: more than one row returned by a subquery used as an expression`. De-duplicate the `generations` insert (or constrain `generations(model_id, code)` UNIQUE).

## Required fix (must satisfy the golden rule)
For **each** affected model:
1. Insert the **official owner's-manual source** into `sources` with a real `url`, `publisher`, `page_reference` (Capacities + Maintenance pages), `confidence_grade='A'`, `access_date`. Match the `document_name` to the `LIKE` pattern the loader expects (or update the loader pattern).
2. Confirm each fluid/maintenance value's **page citation** is the actual page in that manual — do **not** reuse another model's page or invent one.
3. Fix the duplicate `T1XX` generation so the generation lookup is unambiguous.
4. Re-run `data_backend/build_and_export.sh` — it must print `GATE TOTAL = 0` and the file must move from `REJECTED` to `LOADED`.
5. Re-run `functions/scripts/ingest_verified_specs.js` to publish the recovered models to Firestore.

## Acceptance criteria
- [ ] `siyyarte_phase3_gmford.sql` loads clean on PostgreSQL 16 with `ON_ERROR_STOP=1`.
- [ ] `qa_master_gate` total = 0 with the file included.
- [ ] Every recovered value carries source + page + Grade A + `Verified`.
- [ ] The 6 models appear in `verified_specs` and render with verified badges in-app.

## Until then
These models are simply absent from the verified layer; the app shows its **computed general schedule** for them, honestly labelled as non-manufacturer-verified. No incorrect data is shown.
