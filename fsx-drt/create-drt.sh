#!/bin/bash
set -uo pipefail

# -e: Exit immediately if any command fails
# -u: Treat unset variables as an error
# -o pipefail: Consider pipeline failures as well

# Exit if missing arguments
if [ $# -lt 1 ]; then
  echo "[x] Missing arguments"
  exit 1
fi

FILE_SYSTEM_ID="$1"
DAYS_TO_RELEASE="${2:-7}"

aws fsx create-data-repository-task \
--file-system-id "${FILE_SYSTEM_ID}" \
--type RELEASE_DATA_FROM_FILESYSTEM \
--release-configuration "DurationSinceLastAccess={Unit=DAYS,Value=${DAYS_TO_RELEASE}}" \
--report '{"Enabled":false}' > /dev/null

if [ $? -eq 0 ]; then
  echo "[+] Task created"
else
  echo "[x] Task creation failed"
fi
