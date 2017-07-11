-- Deploy libre:0037-journalist-customer to pg
-- requires: 0036-user-plan-cancel-reason

BEGIN;

alter table journalist add column customer_id text;
alter table journalist add column customer_key text;

COMMIT;
