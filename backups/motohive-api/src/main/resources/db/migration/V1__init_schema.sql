-- V1__init_schema.sql
-- Initial schema bootstrap for Motohive

CREATE TABLE IF NOT EXISTS system_info
(
   id         SERIAL PRIMARY KEY,
   KEY VARCHAR (255) NOT NULL UNIQUE,
   value      VARCHAR(255) NOT NULL,
   created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO system_info (key, value)
VALUES ('app.version', '1.0.0-bootstrap');