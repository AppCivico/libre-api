-- Deploy libre:0005-user-session-valid-until to pg
-- requires: 0004-city

BEGIN;

alter table user_session add column valid_until timestamp without time zone not null default now();
alter table user_session alter column valid_until drop default ;

COMMIT;
