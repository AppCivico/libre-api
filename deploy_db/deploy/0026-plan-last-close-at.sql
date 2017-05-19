-- Deploy libre:0026-plan-last-close-at to pg
-- requires: 0025-user-plan-callback-id

BEGIN;

alter table user_plan add column last_close_at timestamp without time zone;

COMMIT;
