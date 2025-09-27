#!/usr/bin/env bash
# extend.sh
set -e

source /var/lib/docker-pgagent/apt/extend.conf

pg_db_enable_pgadmin(){
    if ! su - postgres -c "psql -d postgres -t -c \"SELECT 1 FROM pg_extension WHERE extname = 'pgagent'\"" | grep -q 1; then
        echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') LOG: Enabling pgAgent extension"
        su - postgres -c "psql -d postgres -c \"CREATE EXTENSION pgagent;\"" > /dev/null 2>&1
    fi
}

pg_update_system(){
    if ! test -f "${PG_UPD_STATUS}"; then
        echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') LOG: Updating system..."
        PG_SYS_EXTEND_USER=$(find "${PG_DEB_DIR}" -maxdepth 1 -name "*.deb" -type f -print0 | xargs -0 printf "%s ")
        APT_PKG="${PG_SYS_EXTEND} ${PG_SYS_EXTEND_USER}"
        echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') LOG: Installing packages: ${APT_PKG}"
        # shellcheck disable=SC2086
        apt-get update && apt-get install -y $APT_PKG
        mkdir -p "$(dirname "${PG_UPD_STATUS}")" && echo "done" > "${PG_UPD_STATUS}"
        echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') LOG: System update finished"
    fi
}

pg_terminate_system() {
    local pga_pid run_pid
    pga_pid="$1"
    run_pid="$2"
    echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') [${run_pid}] LOG: Termination requested"
    echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') [${pga_pid}] LOG: Stopping pgAgent..."
    # shellcheck disable=SC2015
    [ -n "${pga_pid}" ] && kill -TERM "${pga_pid}" 2>/dev/null || true
    sleep 2  # Wait for pgAgent to disconnect
    echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') [${run_pid}] LOG: Stopping PostgreSQL..."
    # shellcheck disable=SC2015
    [ -n "${run_pid}" ] && kill -INT "${run_pid}" 2>/dev/null || true
    # Wait for PostgreSQL to exit
    [ -n "${run_pid}" ] && while ps -p "${run_pid}" > /dev/null; do sleep 3; done
}

pg_update_db(){
    pg_db_enable_pgadmin
}