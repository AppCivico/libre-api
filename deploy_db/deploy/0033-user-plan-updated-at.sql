-- Deploy libre:0033-user-plan-updated-at to pg
-- requires: 0032-user-plan-korduv-sync

BEGIN;

alter table user_plan add column updated_at timestamp without time zone ;

COMMIT;
