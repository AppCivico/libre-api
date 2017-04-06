-- Deploy libre:0011-user-flotum to pg
-- requires: 0010-user-pk

BEGIN;

alter table donor add column flotum_id text;
alter table donor add column flotum_preferred_credit_card text;
alter table "user" add column cpf text;

COMMIT;
