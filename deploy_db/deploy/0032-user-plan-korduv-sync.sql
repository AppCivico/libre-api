-- Deploy libre:0032-user-plan-korduv-sync to pg
-- requires: 0031-forgot-password

BEGIN;

alter table user_plan add column first_korduv_sync boolean not null default 'true' ;

COMMIT;
