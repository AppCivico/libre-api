-- Deploy libre:0020-donation-createdat-default to pg
-- requires: 0019-credit

BEGIN;

alter table donation alter column created_at set default current_timestamp;

COMMIT;
