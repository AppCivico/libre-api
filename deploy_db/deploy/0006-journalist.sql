-- Deploy libre:0006-journalist to pg
-- requires: 0005-user-session-valid-until

BEGIN;

CREATE TABLE journalist
(
    id                          SERIAL                      PRIMARY KEY,
    user_id                     integer                     NOT NULL REFERENCES "user"(id),
    user_bank_account_id        integer                     NOT NULL REFERENCES user_bank_account(id),
    name                        text                        NOT NULL,
    surname                     text                        NOT NULL,
    cpf                         text                        UNIQUE,
    rg                          text                        UNIQUE,
    address_state               text                        NOT NULL,
    address_city                text                        NOT NULL,
    address_zipcode             text                        NOT NULL,
    address_street              text                        NOT NULL,
    address_residence_number    text                        NOT NULL,
    address_complement          text,
    cellphone_number            text                        NOT NULL,
    active                      boolean                     NOT NULL DEFAULT FALSE,
    verified                    boolean                     NOT NULL DEFAULT FALSE,
    verified_at                 timestamp without time zone
);

CREATE TABLE bank_institution
(
    id          integer     PRIMARY KEY,
    code        integer     NOT NULL,
    name        text
);

CREATE TABLE user_bank_account
(
    id                      integer     PRIMARY KEY,
    user_id                 integer     NOT NULL REFERENCES "user"(id),
    bank_institution_id     integer     NOT NULL REFERENCES bank_institution(id),
    agency                  text        NOT NULL,
    agency_digit            text        NOT NULL,
    account                 text        NOT NULL,
    account_digit           text        NOT NULL
);

COMMIT;
