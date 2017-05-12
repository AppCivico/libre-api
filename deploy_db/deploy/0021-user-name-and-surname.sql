-- Deploy libre:0021-user-name-and-surname to pg
-- requires: 0020-donation-createdat-default

BEGIN;

ALTER TABLE "user" ADD COLUMN name TEXT;
ALTER TABLE "user" ADD COLUMN surname TEXT;
UPDATE "user"
    SET name       = 'Junior',
        surname    = 'Moares'
    WHERE id = 1;
UPDATE "user" 
    SET name       = d.name,
        surname    = d.surname
    FROM donor as d
    WHERE d.user_id = "user".id;
UPDATE "user" 
    SET name       = j.name,
        surname    = j.surname
    FROM journalist as j
    WHERE j.user_id = "user".id;
UPDATE "user"
    SET name    = 'Junior',
        surname = 'Moares'
    WHERE id = 1;
ALTER TABLE "user" ALTER COLUMN name SET NOT NULL;
ALTER TABLE "user" ALTER COLUMN surname SET NOT NULL;
ALTER TABLE donor DROP COLUMN name, DROP COLUMN surname;
ALTER TABLE journalist DROP COLUMN name, DROP COLUMN surname;

COMMIT;
