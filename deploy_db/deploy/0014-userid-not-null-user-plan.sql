-- Deploy libre:0014-userid-not-null-user-plan to pg
-- requires: 0013-user-plan

BEGIN;

alter table user_plan alter column user_id set not null;

COMMIT;
