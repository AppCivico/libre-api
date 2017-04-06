-- Deploy libre:0012-http-callback-token to pg
-- requires: 0011-user-flotum

BEGIN;

CREATE TABLE http_callback_token
(
  token character varying NOT NULL,
  action character varying NOT NULL,
  extra_args json,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  executed_at timestamp without time zone,
  CONSTRAINT http_callback_token_pkey PRIMARY KEY (token)
);

COMMIT;
