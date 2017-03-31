-- Deploy libre:0003-user-session-valid-until to pg
-- requires: 0002-donor

BEGIN;

alter table user_session add column valid_until timestamp without time zone not null default now();
alter table user_session alter column valid_until drop default ;

COMMIT;
