-- Deploy libre:0000-appschema.t to pg

BEGIN;

CREATE TABLE "user"
(
  id         SERIAL PRIMARY KEY,
  email      text not null unique,
  password   text not null,
  created_at timestamp with time zone NOT NULL DEFAULT now()
) ;

CREATE TABLE role (
    id   INTEGER PRIMARY KEY,
    name TEXT
);

INSERT INTO role VALUES (1, 'admin');
INSERT INTO role VALUES (2, 'user');

CREATE TABLE user_role (
    user_id integer references "user"(id),
    role_id integer references role(id),
    CONSTRAINT user_role_pkey PRIMARY KEY (user_id, role_id)
);

CREATE TABLE user_session
(
  id           serial primary key,
  user_id      integer not null references "user"(id),
  api_key      text not null unique,
  created_at   timestamp without time zone not null default now()
);


INSERT INTO "user" (password, email) VALUES ('$2a$08$J.6n3gDaI557928Pa746deLFIknPMoyCo692RwAjVf0ToIFTI73vq', 'juniorfvox@gmail.com') ;
INSERT INTO user_role (role_id, user_id) VALUES (1, 1) ;

COMMIT;
