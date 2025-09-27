#!/usr/bin/env bash
# deploy-in-container.sh
set -e
echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') LOG: Deploying docker-pgagent.."
cp -a /root/deploy/pg_ext/. /var/lib/docker-pgagent/
echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') LOG: Coping additional extensions"
find /root/extra_packages -name "*.deb" -type f -exec cp {} /var/lib/docker-pgagent/apt/pkg/ \;
echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') LOG: Restoring file permissions..."
bash /var/lib/docker-pgagent/fix-permissions.sh
tree /var/lib/docker-pgagent
ls -lha /var/lib/docker-pgagent
echo "$(date -u '+%Y-%m-%d %H:%M:%S.%3N %Z') LOG: Deployment of docker-pgagent complete"
