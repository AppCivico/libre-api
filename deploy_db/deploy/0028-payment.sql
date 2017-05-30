-- Deploy libre:0028-payment to pg
-- requires: 0027-invalided-at

BEGIN;

create table payment (
    id             serial primary key,
    donor_id       integer not null references "user"(id),
    amount         integer not null,
    user_plan_id   integer not null references user_plan(id),
    gateway_tax    numeric(3, 2) not null,
    created_at     timestamp without time zone not null default now()
);

COMMIT;
