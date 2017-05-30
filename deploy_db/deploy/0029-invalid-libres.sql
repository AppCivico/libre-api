-- Deploy libre:0029-invalid-libres to pg
-- requires: 0028-payment

BEGIN;

ALTER TABLE libre ADD COLUMN invalid boolean NOT NULL DEFAULT FALSE;
ALTER TABLE libre ADD COLUMN invalided_at timestamp without time zone;
ALTER TABLE libre ADD COLUMN orphaned_at timestamp without time zone;

COMMIT;
