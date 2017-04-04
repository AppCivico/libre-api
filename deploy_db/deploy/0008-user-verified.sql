-- Deploy libre:0008-user-verified to pg
-- requires: 0007-journalist-bank-account-nullable

BEGIN;

alter table journalist drop column verified ;
alter table "user" add column verified boolean not null default true;
alter table "user" alter column verified drop default;
alter table "user" add column verified_at timestamp without time zone ;
update "user" set verified_at = now() where verified = 'true' and verified_at is null ;

COMMIT;
