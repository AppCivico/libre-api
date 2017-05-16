-- Deploy libre:0023-plan-closed-at to pg
-- requires: 0022-donation-to-support

BEGIN;

alter table user_plan add column closed_at timestamp without time zone ;

COMMIT;
