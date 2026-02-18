-- Observability: extensions and read-only user for metrics (e.g. Grafana).
-- Server parameters (e.g. track_activity_query_size) are in docker/postgres/custom.conf.
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT pg_reload_conf();

CREATE USER "db-o11y" WITH PASSWORD 'db-o11y';
GRANT pg_monitor TO "db-o11y";
GRANT pg_read_all_stats TO "db-o11y";
ALTER ROLE "db-o11y" SET pg_stat_statements.track = 'none';

-- Grant object privileges for schema_details (required per Database Observability docs).
-- Must be done in each logical database that autodiscovery will query.
GRANT pg_read_all_data TO "db-o11y";

-- Also create extension and grants in pagila (primary app database)
\connect pagila
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
GRANT USAGE ON SCHEMA public TO "db-o11y";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "db-o11y";
GRANT pg_read_all_data TO "db-o11y";