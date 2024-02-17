#!/bin/bash
set -euo pipefail

# -e: Exit immediately if any command fails
# -u: Treat unset variables as an error
# -o pipefail: Consider pipeline failures as well

TIME_TO_SLEEP=${1:-30}

echo "[-] Start at $(date)"
echo "[-] Running a script on $(hostname)"

if [[ -z ${SLURM_JOB_ID+x} ]]; then
  echo "\$SLURM_JOB_ID is not set. This script is not running in a SLURM job."
else
  echo "[-] Job information:"
  echo "[-] Slurm job details for job: $SLURM_JOB_ID"
  scontrol show job "$SLURM_JOB_ID"
fi

echo "[-] Sleeping for $TIME_TO_SLEEP seconds"
sleep "$TIME_TO_SLEEP"
echo "[-] Done at $(date)"
echo
echo "Finished!"
