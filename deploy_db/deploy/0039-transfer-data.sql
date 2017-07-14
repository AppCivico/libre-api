-- Deploy libre:0039-transfer-data to pg
-- requires: 0038-donor-cpf

BEGIN;

alter table money_transfer add column transfer_id text;
alter table money_transfer add column transfer_status text;

COMMIT;
