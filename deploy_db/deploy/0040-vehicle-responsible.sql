-- Deploy libre:0040-vehicle-responsible to pg
-- requires: 0039-transfer-data

BEGIN;

ALTER TABLE journalist ADD COLUMN responsible_name  TEXT;
ALTER TABLE journalist ADD COLUMN responsible_email TEXT UNIQUE;
ALTER TABLE journalist ADD COLUMN responsible_cpf   TEXT UNIQUE;

COMMIT;
