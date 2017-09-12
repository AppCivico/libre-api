-- Deploy libre:0044-money-transfer-traceability to pg
-- requires: 0043-vehicle-responsible-surname

BEGIN;

alter table money_transfer add column from_donor_id integer references "user"(id) ;
alter table money_transfer add column from_payment_id integer references payment(id) ;
alter table money_transfer add column supports_received integer not null default 0;
alter table money_transfer alter column supports_received drop default;
alter table money_transfer add column donor_plan_last_close_at timestamp without time zone ;

COMMIT;
