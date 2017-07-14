-- Deploy libre:0038-donor-cpf to pg
-- requires: 0037-journalist-customer

BEGIN;

ALTER TABLE donor ADD COLUMN cpf TEXT UNIQUE;
UPDATE donor
    SET cpf = u.cpf
    FROM "user" as u
    WHERE donor.user_id = u.id;
ALTER TABLE donor ALTER COLUMN cpf SET DEFAULT '';
ALTER TABLE donor ALTER COLUMN cpf SET NOT NULL;
ALTER TABLE donor ALTER COLUMN cpf DROP DEFAULT; 
ALTER TABLE "user" DROP COLUMN cpf;

COMMIT;
