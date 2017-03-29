-- Deploy libre:0001-email-queue to pg
-- requires: 0000-appschema

BEGIN;

create table email_queue (
    id serial  primary key,
    body text  not null,
    bcc  text[],
    created_at timestamp without time zone not null default now()
);

COMMIT;
