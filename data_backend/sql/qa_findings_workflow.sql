-- =====================================================================
-- Siyyarte — Data-issue triage workflow (Phase 9, Workstream D)
-- Downgrade-first: never silently overwrite a production value.
-- =====================================================================
BEGIN;
-- allow UNDER_REVIEW status
ALTER TABLE qa_findings DROP CONSTRAINT IF EXISTS qa_findings_current_status_check;
ALTER TABLE qa_findings ADD CONSTRAINT qa_findings_current_status_check
  CHECK (current_status IN ('OPEN','IN_PROGRESS','UNDER_REVIEW','RESOLVED','WONTFIX'));

-- preserve original values on any downgrade
CREATE TABLE IF NOT EXISTS value_history (
    history_id  BIGSERIAL PRIMARY KEY,
    table_name  TEXT, row_id BIGINT, field TEXT,
    old_value   TEXT, old_status TEXT, old_grade confidence_grade,
    reason      TEXT, archived_at TIMESTAMPTZ DEFAULT now()
);

-- flag a reported fluid field Under_Review: history -> downgrade -> finding (Workstream D steps 1-4)
CREATE OR REPLACE FUNCTION flag_fluid_under_review(p_id BIGINT, p_reason TEXT, p_vehicle TEXT) RETURNS void AS $$
DECLARE r spec_fluids%ROWTYPE; BEGIN
  SELECT * INTO r FROM spec_fluids WHERE id=p_id;
  INSERT INTO value_history(table_name,row_id,field,old_value,old_status,old_grade,reason)
    VALUES('spec_fluids',p_id,r.fluid_type, r.specification||' / '||COALESCE(r.capacity_value::text,'')||COALESCE(r.capacity_unit,''), r.verification_status::text, r.confidence_grade, p_reason);
  UPDATE spec_fluids SET verification_status='Not Verified' WHERE id=p_id;  -- removed from renderable Verified_A
  INSERT INTO qa_findings(affected_vehicle,affected_fields,original_source,suspected_issue,required_fix,severity,current_status)
    VALUES(p_vehicle, r.fluid_type, 'see source_id '||COALESCE(r.source_id::text,'NULL'), p_reason,
           'Re-check official source; restore only if confirmed, else keep Verification_Pending/Blocked.', 'HIGH','UNDER_REVIEW');
END; $$ LANGUAGE plpgsql;

-- restore after confirmation (Workstream D step 6)
CREATE OR REPLACE FUNCTION restore_fluid(p_id BIGINT, p_finding BIGINT) RETURNS void AS $$
BEGIN
  UPDATE spec_fluids SET verification_status='Verified', verification_date=CURRENT_DATE WHERE id=p_id AND confidence_grade='A' AND source_id IS NOT NULL;
  UPDATE qa_findings SET current_status='RESOLVED' WHERE finding_id=p_finding;
END; $$ LANGUAGE plpgsql;
COMMIT;
