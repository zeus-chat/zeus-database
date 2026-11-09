--liquibase formatted sql

--changeset team:0002-ddl-create-chat-app-role splitStatements:false
-- Group role for the chat-service. NOLOGIN on purpose: login users and passwords are
-- created outside Git for each environment and granted this role.
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'chat_app') THEN
        CREATE ROLE chat_app NOLOGIN;
    END IF;
END
$$;
GRANT USAGE ON SCHEMA chat TO chat_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA chat GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO chat_app;
--rollback ALTER DEFAULT PRIVILEGES IN SCHEMA chat REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLES FROM chat_app;
--rollback REVOKE USAGE ON SCHEMA chat FROM chat_app;
