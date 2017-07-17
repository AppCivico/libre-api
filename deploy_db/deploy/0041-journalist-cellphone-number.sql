-- Deploy libre:0041-journalist-cellphone-number to pg
-- requires: 0040-vehicle-responsible

BEGIN;

ALTER TABLE journalist ALTER COLUMN cellphone_number SET DEFAULT '';
ALTER TABLE journalist ALTER COLUMN cellphone_number SET NOT NULL;
ALTER TABLE journalist ALTER COLUMN cellphone_number DROP DEFAULT;

COMMIT;
