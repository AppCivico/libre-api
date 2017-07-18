-- Deploy libre:0043-vehicle-responsible-surname to pg
-- requires: 0042-vehicle-name

BEGIN;

ALTER TABLE journalist DROP CONSTRAINT journalist_responsible_email_key;
ALTER TABLE journalist RENAME responsible_email TO responsible_surname;

COMMIT;
