-- Deploy libre:0035-user-plan-canceled to pg
-- requires: 0034-libre-page-data

BEGIN;

alter table user_plan add column canceled boolean not null default 'false';

COMMIT;
