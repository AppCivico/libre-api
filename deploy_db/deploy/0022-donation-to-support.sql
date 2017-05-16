-- Deploy libre:0022-donation-to-support to pg
-- requires: 0021-user-name-and-surname

BEGIN;

ALTER TABLE donation ADD COLUMN user_plan_id INTEGER REFERENCES user_plan(id);
ALTER TABLE donation RENAME TO libre;
ALTER SEQUENCE donation_id_seq RENAME TO libre_id_seq;
ALTER TABLE credit RENAME donation_id TO libre_id;

COMMIT;
