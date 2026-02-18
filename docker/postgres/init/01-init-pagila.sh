#!/bin/sh
set -e

# Load Pagila schema and data from GitHub (https://github.com/devrimgunduz/pagila)
# Database "pagila" is created by 00-create-pagila-db.sql
echo "Loading Pagila schema..."
curl -sSL "https://raw.githubusercontent.com/devrimgunduz/pagila/master/pagila-schema.sql" | \
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d pagila

echo "Loading Pagila data..."
curl -sSL "https://raw.githubusercontent.com/devrimgunduz/pagila/master/pagila-data.sql" | \
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d pagila

echo "Pagila sample database ready."
