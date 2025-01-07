aws ssm create-document \
--content file://wait_for_cloud_init.yml \
--name "wait-for-cloud-init" \
--document-format YAML \
--document-type "Command"

# RES
aws ssm create-association \
--name AWS-RunPatchBaselineWithHooks \
 --targets Key=tag:"res:EnvironmentName",Values="<res-environment-name>" \
 --association-name "<res-environment-name>_updates" \
 --parameters PreInstallHookDocName=wait-for-cloud-init,Operation=Scan,RebootOption=RebootIfNeeded

# ParallelCluster Compute
aws ssm create-association \
--name AWS-RunPatchBaselineWithHooks \
 --targets Key=tag:"parallelcluster:node-type",Values="Compute" \
 --association-name "parallelcluster-compute_updates" \
 --parameters PreInstallHookDocName=wait-for-cloud-init,Operation=Scan,RebootOption=NoReboot

aws ssm update-association \
--name AWS-RunPatchBaselineWithHooks \
 --targets Key=tag:"parallelcluster:node-type",Values="Compute" \
 --association-name "parallelcluster-compute_updates" \
 --parameters PreInstallHookDocName=wait-for-cloud-init,Operation=Scan,RebootOption=NoReboot \
 --association-id 4537dcbe-4d4e-48dd-a4f8-d9acd7552e1e

aws ssm delete-association \
--association-id 4537dcbe-4d4e-48dd-a4f8-d9acd7552e1e
