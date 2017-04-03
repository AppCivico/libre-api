-- Deploy libre:0007-journalist-bank-account-nullable to pg
-- requires: 0006-journalist

BEGIN;

DROP TABLE journalist;

DROP TABLE user_bank_account;

DROP TABLE bank_institution;

CREATE TABLE bank_institution
(
    id          SERIAL     PRIMARY KEY,
    code        text       NOT NULL,
    name        text
);

CREATE TABLE user_bank_account
(
    id                      SERIAL     PRIMARY KEY,
    bank_institution_id     integer     NOT NULL REFERENCES bank_institution(id),
    agency                  text        NOT NULL,
    account                 text        NOT NULL
);

CREATE TABLE journalist
(
    id                       SERIAL                      PRIMARY KEY,
    user_id                  integer                     NOT NULL REFERENCES "user"(id),
    user_bank_account_id     integer                     REFERENCES user_bank_account(id),
    name                     text                        NOT NULL,
    surname                  text                        NOT NULL,
    rg                       text                        NOT NULL,
    cpf                      text                        UNIQUE,
    address_state            text                        NOT NULL,
    address_city             text                        NOT NULL,
    address_zipcode          text                        NOT NULL,
    address_street           text                        NOT NULL,
    address_residence_number text                        NOT NULL,
    address_complement       text,
    cellphone_number         text,
    active                   boolean                     NOT NULL DEFAULT FALSE,
    verified                 boolean                     NOT NULL DEFAULT FALSE,
    verified_at              timestamp without time zone
);

INSERT INTO bank_institution (code, name) VALUES (719,'Banco Banif'), (107,'Banco BBM'), (318,'Banco BMG'), (218,'Banco Bonsucesso'), (208,'Banco BTG Pactual'), (263,'Banco Cacique'), (263,'Banco Caixa Geral - Brasil'), (745,'Banco Citibank'), (721,'Banco Credibel'), (505,'Banco Credit Suisse'), (707,'Banco Daycoval'), (265,'Banco Fator'), (224,'Banco Fibra'), (121,'Banco Gerador'), (612,'Banco Guanabara'), (604,'Banco Industrial do Brasil'), (320,'Banco Industrial e Comercial'), (653,'Banco Indusval'), (77,'Banco Intermedium'), (184,'Banco Itaú BBA'), (479,'Banco ItaúBank'), (389,'Banco Mercantil do Brasil'), (746,'Banco Modal'), (738,'Banco Morada'), (623,'Banco Pan'), (611,'Banco Paulista'), (643,'Banco Pine'), (654,'Banco Renner'), (741,'Banco Ribeirão Preto'), (422,'Banco Safra'), (33,'Banco Santander'),(637,'Banco Sofisa'), (82,'Banco Topázio'), (655,'Banco Votorantim'), (237,'Bradesco'), (341,'Itaú Unibanco');

COMMIT;
