-- Deploy libre:0017-donation-relation to pg
-- requires: 0016-user-plan-fix

BEGIN;

ALTER TABLE donation DROP COLUMN user_id;
ALTER TABLE donation DROP COLUMN journalist_id;
ALTER TABLE donation ADD COLUMN donor_user_id integer NOT NULL REFERENCES "user"(id);
ALTER TABLE donation ADD COLUMN journalist_user_id integer NOT NULL REFERENCES "user"(id);

COMMIT;
