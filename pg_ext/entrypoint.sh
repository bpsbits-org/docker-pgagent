#!/usr/bin/env bash
# entrypoint.sh
set -e
echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') LOG: Initializing..."
source /var/lib/docker-pgagent/apt/extend.sh
pg_update_system
trap 'pg_terminate_system "$PGA_PID" "$RUN_PID"; exit 0' TERM INT
POSTGRES_USER=postgres /usr/local/bin/docker-entrypoint.sh postgres & RUN_PID=$!
until PGUSER=postgres pg_isready; do sleep 1; done
echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') [${RUN_PID}] LOG: PostgreSQL started"
pg_update_db
su - postgres -c "${PG_RUN_AGENT}" & PGA_PID=$!
echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') [${PGA_PID}] LOG: pgAgent started"
wait $RUN_PID