#!/usr/bin/env bash
set -e
readonly FILE_DPT="${SSC_ARGV0:-${BASH_SOURCE[0]}}"
DIR_PRJ="$(dirname "${FILE_DPT}")"
PATH_DIR_PACKAGES=$(realpath "${DIR_PRJ}/../_local/pkg")

echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Testing deployment image"

set +e
echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Cleaning up previous run..."
podman secret rm ps_pg_server 2>/dev/null || true
podman stop postgres_with_pg_agent >/dev/null 2>&1
podman rm --force postgres_with_pg_agent >/dev/null 2>&1
podman volume rm vol_tmp_ext >/dev/null 2>&1
podman volume rm vol_docker_pgagent >/dev/null 2>&1
podman volume rm vol_postgres_data >/dev/null 2>&1
set -e

echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Creating volumes..."
podman volume create vol_tmp_ext >/dev/null 2>&1
podman volume create vol_docker_pgagent >/dev/null 2>&1
podman volume create vol_postgres_data >/dev/null 2>&1
echo -n "12345678" | podman secret create ps_pg_server - >/dev/null 2>&1

echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Coping custom debian packages..."
podman run --rm \
    -v "${PATH_DIR_PACKAGES}:/source:z" \
    -v vol_tmp_ext:/root/extra_packages:z \
    --platform linux/amd64 \
    docker.io/library/debian:trixie-slim cp -rv /source/. /root/extra_packages/

echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Installing docker-pgagent"
podman run --rm \
    -v vol_tmp_ext:/root/extra_packages:z \
    -v vol_docker_pgagent:/var/lib/docker-pgagent:z \
    --platform linux/amd64 \
    quay.io/pg_share/docker_pgagent:pg17
podman volume rm vol_tmp_ext >/dev/null 2>&1

echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Checking installation"
podman run --rm -v vol_docker_pgagent:/var/lib/docker-pgagent:z alpine tree /var/lib/docker-pgagent

echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Creating postgres container"
podman create \
    --name postgres_with_pg_agent \
    --restart always \
    -v vol_docker_pgagent:/var/lib/docker-pgagent:z \
    -v vol_postgres_data:/var/lib/postgresql/data:z \
    -p 5438:5432 \
    --secret ps_pg_server,type=env,target=POSTGRES_PASSWORD \
    --entrypoint /var/lib/docker-pgagent/entrypoint.sh \
    --platform linux/amd64 \
    docker.io/library/postgres:17

echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Running postgres container"
podman start postgres_with_pg_agent

set +e
timeout 80 podman logs -f postgres_with_pg_agent
set -e

set +e
echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Cleaning up..."
podman stop postgres_with_pg_agent >/dev/null 2>&1
podman rm --force postgres_with_pg_agent >/dev/null 2>&1
podman volume rm vol_tmp_ext >/dev/null 2>&1
podman volume rm vol_docker_pgagent >/dev/null 2>&1
podman volume rm vol_postgres_data >/dev/null 2>&1
set -e

echo "$(gdate -u '+%Y-%m-%d %H:%M:%S.%3N %Z') Testing complete"