-- Deploy libre:0045-libre-computed to pg
-- requires: 0044-money-transfer-traceability

BEGIN;

alter table libre add column computed boolean not null default false;
alter table libre add column computed_at timestamp without time zone ;

COMMIT;
