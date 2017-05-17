-- Deploy libre:0024-plan-canceled-at to pg
-- requires: 0023-plan-closed-at

BEGIN;

alter table user_plan rename column closed_at to canceled_at ;

COMMIT;
