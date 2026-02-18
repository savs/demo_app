#!/bin/sh
set -e
# Include custom.conf so the main server (started after init) loads overrides.
# Idempotent: skip if already present.
INCLUDE_LINE="include = '/etc/postgresql/custom.conf'"
grep -qF "$INCLUDE_LINE" "$PGDATA/postgresql.conf" || echo "$INCLUDE_LINE" >> "$PGDATA/postgresql.conf"
