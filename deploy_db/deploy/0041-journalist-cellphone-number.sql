-- Deploy libre:0041-journalist-cellphone-number to pg
-- requires: 0040-vehicle-responsible

BEGIN;

UPDATE journalist SET cellphone_number = '' WHERE cellphone_number IS NULL;
ALTER TABLE journalist ALTER COLUMN cellphone_number SET NOT NULL;

COMMIT;
