-- Deploy libre:0030-money-transfer to pg
-- requires: 0029-invalid-libres

BEGIN;

create table money_transfer (
    id              serial primary key,
    amount          integer not null,
    journalist_id   integer not null references journalist(user_id),
    created_at      timestamp without time zone not null default now(),
    transferred     boolean not null default 'false',
    transferred_at  timestamp without time zone
);

COMMIT;
