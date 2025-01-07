#!/bin/bash

set -eou pipefail

# accept RES_ENVIRONMENT as argument to script
if [ $# -eq 0 ]; then
  echo "No arguments provided"
  echo "Usage: $0 <RES_ENVIRONMENT>"
  exit 1
fi

RES_ENVIRONMENT=$1

echo "Creating wait-for-cloud-init document..."

aws ssm create-document \
--content file://assets/ssm/wait_for_cloud_init.yml \
--name "wait-for-cloud-init" \
--document-format YAML \
--document-type "Command"

echo "Creating wait-for-cloud-init association for RES ..."

aws ssm create-association \
--name AWS-RunPatchBaselineWithHooks \
 --targets Key=tag:"res:EnvironmentName",Values="$RES_ENVIRONMENT" \
 --association-name "$RES_ENVIRONMENT_updates" \
 --parameters PreInstallHookDocName=wait-for-cloud-init,Operation=Scan,RebootOption=RebootIfNeeded

echo "Creating wait-for-cloud-init association for ParallelCluster ..."

aws ssm create-association \
--name AWS-RunPatchBaselineWithHooks \
 --targets Key=tag:"parallelcluster:node-type",Values="Compute" \
 --association-name "parallelcluster-compute_updates" \
 --parameters PreInstallHookDocName=wait-for-cloud-init,Operation=Scan,RebootOption=NoReboot
