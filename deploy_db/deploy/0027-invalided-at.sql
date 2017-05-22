-- Deploy libre:0027-invalided-at to pg
-- requires: 0026-plan-last-close-at

BEGIN;

ALTER TABLE user_plan ADD COLUMN invalided_at timestamp without time zone;

COMMIT;
