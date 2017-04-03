-- Deploy libre:0007-journalist-bank-account-nullable to pg
-- requires: 0006-journalist

BEGIN;

ALTER TABLE journalist ALTER COLUMN user_bank_account_id DROP NOT NULL;

ALTER TABLE journalist ALTER COLUMN cellphone_number DROP NOT NULL;

INSERT INTO bank_institution (code, name) VALUES (719,'Banco Banif'), (107,'Banco BBM'), (318,'Banco BMG'), (218,'Banco Bonsucesso'), (208,'Banco BTG Pactual'), (263,'Banco Cacique'), (263,'Banco Caixa Geral - Brasil'), (745,'Banco Citibank'), (721,'Banco Credibel'), (505,'Banco Credit Suisse'), (707,'Banco Daycoval'), (265,'Banco Fator'), (224,'Banco Fibra'), (121,'Banco Gerador'), (612,'Banco Guanabara'), (604,'Banco Industrial do Brasil'), (320,'Banco Industrial e Comercial'), (653,'Banco Indusval'), (77,'Banco Intermedium'), (184,'Banco Itaú BBA'), (479,'Banco ItaúBank'), (389,'Banco Mercantil do Brasil'), (746,'Banco Modal'), (738,'Banco Morada'), (623,'Banco Pan'), (611,'Banco Paulista'), (643,'Banco Pine'), (654,'Banco Renner'), (741,'Banco Ribeirão Preto'), (422,'Banco Safra'), (33,'Banco Santander'),(637,'Banco Sofisa'), (82,'Banco Topázio'), (655,'Banco Votorantim'), (237,'Bradesco'), (341,'Itaú Unibanco');

COMMIT;
