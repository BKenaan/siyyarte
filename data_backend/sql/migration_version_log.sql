-- Siyyarte migration / release version log
CREATE TABLE IF NOT EXISTS release_versions (
    version       TEXT PRIMARY KEY,        -- e.g. 'beta_dataset_v0_1'
    released_at   TIMESTAMPTZ DEFAULT now(),
    dataset_sha256 CHAR(64),               -- hash of the concatenated load files (release integrity)
    qa_gate_total INT,                     -- must be 0 to promote
    promoted_to   TEXT CHECK (promoted_to IN ('staging','production','rolled_back')),
    notes         TEXT
);
INSERT INTO release_versions (version,dataset_sha256,qa_gate_total,promoted_to,notes)
VALUES ('beta_dataset_v0_1', NULL, 0, 'staging', 'Initial beta freeze; qa_master_gate asserted 0 at load')
ON CONFLICT (version) DO NOTHING;
