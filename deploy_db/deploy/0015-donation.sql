-- Deploy libre:0015-donation to pg
-- requires: 0014-userid-not-null-user-plan

BEGIN;

CREATE TABLE  donation
(
    id              SERIAL                          PRIMARY KEY,
    user_id         integer                         NOT NULL REFERENCES donor(user_id),
    journalist_id   integer                         NOT NULL REFERENCES journalist(user_id),
    created_at      timestamp without time zone     NOT NULL
);

COMMIT;
