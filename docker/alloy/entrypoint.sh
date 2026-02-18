#!/bin/sh
set -e

# Write Postgres DSN for Alloy from env (postgres_secret_pagila).
# Format: postgresql://DB_USER:DB_PASSWORD@DB_HOST:DB_PORT/DB_DATABASE?sslmode=...
# Password with special characters (e.g. @, :) should be URL-encoded.
DB_USER="${DB_USER:-db-o11y}"
DB_PASSWORD="${DB_PASSWORD:-db-o11y}"
DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_DATABASE="${DB_DATABASE:-pagila}"
DB_SSLMODE="${DB_SSLMODE:-disable}"

mkdir -p /var/lib/alloy
# No trailing newline: Alloy uses the file content as the URL directly
printf 'postgresql://%s:%s@%s:%s/%s?sslmode=%s' \
  "$DB_USER" "$DB_PASSWORD" "$DB_HOST" "$DB_PORT" "$DB_DATABASE" "$DB_SSLMODE" \
  > /var/lib/alloy/postgres_secret_pagila
chmod 600 /var/lib/alloy/postgres_secret_pagila

exec /bin/alloy "$@"
