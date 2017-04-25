-- Deploy libre:0019-credit to pg
-- requires: 0018-vehicle

BEGIN;

alter table donation rename column donor_user_id to donor_id ;
alter table donation rename column journalist_user_id to journalist_id ;

create table credit (
    id             serial primary key,
    donation_id    integer not null references donation(id),
    paid           boolean not null default 'false',
    paid_at        timestamp without time zone,
    created_at     timestamp without time zone not null default now()
);

COMMIT;
