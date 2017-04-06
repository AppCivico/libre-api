-- Deploy libre:0010-user-pk to pg
-- requires: 0009-remove-rg

BEGIN;

alter table donor drop column id;
alter table donor add primary key (user_id);

alter table journalist drop column id;
alter table journalist add primary key (user_id);

COMMIT;
