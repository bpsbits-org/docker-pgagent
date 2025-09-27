#!/usr/bin/env bash
# fix-permissions.sh
set -e
readonly FILE_SCRIPT="${SSC_ARGV0:-${BASH_SOURCE[0]}}"
DIR_SCRIPT="$(dirname "${FILE_SCRIPT}")"
readonly DIR_SCRIPT
DIR_PG_EXT="$(dirname "${DIR_SCRIPT}")"
readonly DIR_PG_EXT
chown -R root:root "${DIR_PG_EXT}"
chmod 750 "${DIR_PG_EXT}"
find "${DIR_PG_EXT}" -type d -exec chmod 750 {} \;
find "${DIR_PG_EXT}" -type f -exec chmod 640 {} \;
find "${DIR_PG_EXT}" -name "*.sh" -exec chmod 755 {} \;