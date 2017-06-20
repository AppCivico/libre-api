-- Deploy libre:0036-user-plan-cancel-reason to pg
-- requires: 0035-user-plan-canceled

BEGIN;

alter table user_plan add column cancel_reason text;

COMMIT;
