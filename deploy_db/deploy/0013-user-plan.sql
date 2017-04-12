-- Deploy libre:0013-user-plan to pg
-- requires: 0012-http-callback-token

BEGIN;

CREATE TABLE user_plan
(
    id          SERIAL                          PRIMARY KEY,
    user_id     integer                         REFERENCES "user"(id),
    amount      numeric(8, 2)                   NOT NULL UNIQUE,
    created_at  timestamp without time zone     NOT NULL,
    valid_until timestamp without time zone     NOT NULL
);

COMMIT;
