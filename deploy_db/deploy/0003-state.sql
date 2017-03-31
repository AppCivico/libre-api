-- Deploy saveh:0067-state to pg
-- requires: 0066-notification-sent

BEGIN;

CREATE TABLE state (
    id   INTEGER PRIMARY KEY,
    code TEXT NOT NULL,
    name TEXT NOT NULL
);

INSERT INTO state VALUES (1, 'AC', 'Acre');
INSERT INTO state VALUES (2, 'AL', 'Alagoas');
INSERT INTO state VALUES (3, 'AM', 'Amazonas');
INSERT INTO state VALUES (4, 'AP', 'Amapá');
INSERT INTO state VALUES (5, 'BA', 'Bahia');
INSERT INTO state VALUES (6, 'CE', 'Ceará');
INSERT INTO state VALUES (7, 'DF', 'Distrito Federal');
INSERT INTO state VALUES (8, 'ES', 'Espírito Santo');
INSERT INTO state VALUES (9, 'GO', 'Goiás');
INSERT INTO state VALUES (10, 'MA', 'Maranhão');
INSERT INTO state VALUES (11, 'MG', 'Minas Gerais');
INSERT INTO state VALUES (12, 'MS', 'Mato Grosso do Sul');
INSERT INTO state VALUES (13, 'MT', 'Mato Grosso');
INSERT INTO state VALUES (14, 'PA', 'Pará');
INSERT INTO state VALUES (15, 'PB', 'Paraíba');
INSERT INTO state VALUES (16, 'PE', 'Pernambuco');
INSERT INTO state VALUES (17, 'PI', 'Piauí');
INSERT INTO state VALUES (18, 'PR', 'Paraná');
INSERT INTO state VALUES (19, 'RJ', 'Rio de Janeiro');
INSERT INTO state VALUES (20, 'RN', 'Rio Grande do Norte');
INSERT INTO state VALUES (21, 'RO', 'Rondônia');
INSERT INTO state VALUES (22, 'RR', 'Roraima');
INSERT INTO state VALUES (23, 'RS', 'Rio Grande do Sul');
INSERT INTO state VALUES (24, 'SC', 'Santa Catarina');
INSERT INTO state VALUES (25, 'SE', 'Sergipe');
INSERT INTO state VALUES (26, 'SP', 'São Paulo');
INSERT INTO state VALUES (27, 'TO', 'Tocantins');

COMMIT;
