-- Deploy libre:0042-vehicle-name to pg
-- requires: 0041-journalist-cellphone-number

BEGIN;

ALTER TABLE "user" ALTER surname DROP NOT NULL;

COMMIT;
