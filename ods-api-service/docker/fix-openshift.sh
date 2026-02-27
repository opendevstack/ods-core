#!/bin/sh

# Force correct user — override Alpine entrypoint using container UID
export USER=postgres
export PGUSER=postgres
export POSTGRES_USER=postgres

# Execute the real Postgres entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@"