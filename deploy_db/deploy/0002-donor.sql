-- Deploy libre:0002-donor to pg
-- requires: 0001-email-queue

BEGIN;

create table donor (
    id      serial primary key,
    user_id integer not null references "user"(id),
    name    text not null,
    surname text not null,
    phone   text
);

update role set name = 'journalist' where id = 2;
insert into role (id, name) values (3, 'donor') ;

COMMIT;
