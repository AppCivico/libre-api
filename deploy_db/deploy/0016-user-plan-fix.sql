-- Deploy libre:0016-user-plan-fix to pg
-- requires: 0015-donation

BEGIN;

alter table user_plan alter column amount type integer ;
alter table user_plan alter column created_at set default current_timestamp ;
alter table user_plan alter column valid_until drop not null ;
alter table user_plan drop constraint user_plan_amount_key ;

COMMIT;
