-- Deploy libre:0009-remove-rg to pg
-- requires: 0008-user-verified

BEGIN;

alter table journalist drop column rg;

COMMIT;
