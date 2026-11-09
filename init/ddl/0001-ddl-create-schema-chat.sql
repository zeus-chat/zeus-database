--liquibase formatted sql

--changeset team:0001-ddl-create-schema-chat
CREATE SCHEMA IF NOT EXISTS chat;
--rollback DROP SCHEMA IF EXISTS chat;
