-- Deploy libre:0034-libre-page-data to pg
-- requires: 0033-user-plan-updated-at

BEGIN;

alter table libre add column page_title text not null default '';
alter table libre add column page_referer text not null default '';
alter table libre alter column page_title drop default;
alter table libre alter column page_referer drop default;

COMMIT;
