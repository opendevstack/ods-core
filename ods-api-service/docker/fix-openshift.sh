#!/bin/sh

# Force correct user — override Alpine entrypoint using container UID
export USER=postgres
export PGUSER=postgres
export POSTGRES_USER=postgres

# Prevent entrypoint from trying to chmod /var/run/postgresql
mkdir -p /var/run/postgresql
chmod 775 /var/run/postgresql

# Execute the real Postgres entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"