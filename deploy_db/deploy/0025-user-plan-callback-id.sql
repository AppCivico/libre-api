-- Deploy libre:0025-user-plan-callback-id to pg
-- requires: 0024-plan-canceled-at

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

BEGIN;

alter table user_plan add column callback_id uuid NOT NULL DEFAULT uuid_generate_v4();

COMMIT;
