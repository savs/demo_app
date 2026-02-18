FROM postgres:16-alpine

# Install curl to fetch Pagila schema and data on init
RUN apk add --no-cache curl ca-certificates

# Configuration overrides (included from main postgresql.conf via init/03-include-overrides.sh)
RUN install -d -o postgres -g postgres /etc/postgresql
COPY custom.conf /etc/postgresql/custom.conf
RUN chown postgres:postgres /etc/postgresql/custom.conf
