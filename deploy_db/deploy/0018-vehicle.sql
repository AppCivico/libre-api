-- Deploy libre:0018-vehicle to pg
-- requires: 0017-donation-relation

BEGIN;

ALTER TABLE journalist ADD COLUMN cnpj text;
ALTER TABLE journalist ADD COLUMN vehicle boolean NOT NULL;

COMMIT;
