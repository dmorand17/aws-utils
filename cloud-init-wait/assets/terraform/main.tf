provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "dev"
      cost-center = "111111"
      ManagedBy   = "Terraform"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # This sets the version constraint to a minimum of 1.10 for native state file locking support
  required_version = "~> 1.10"
}

# Create the SSM document
resource "aws_ssm_document" "wait_for_cloud_init" {
  name            = "wait-for-cloud-init"
  document_type   = "Command"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '2.2'
description: 'Document to delay patching until after cloud-init.'
mainSteps:
- action: 'aws:runShellScript'
  name: 'WaitForCloudInit' 
  inputs:
    runCommand:
    - | 
      touch /root/patch-pending
      rm -f /root/patch-continue
      rm -f /root/patch-ready 
      rm -f /root/patch-done

      count=0
      max_count=300

      echo "Waiting 1 minute to allow cloud-init to start."
      sleep 60

      while ps -efww | grep cloud-init | grep -v 'grep cloud-init'; do
          if [[ $count > $max_count ]]; then
              echo "Have waited max time of $max_count minutes so allowing patch to continue."
              exit 0
          fi
          echo "cloud-init running. Waiting 60s for it to finish."
          sleep 60
      done
      echo "cloud-init not running. Patching can proceed."
      rm -f /root/patch-pending
      touch /root/patch-ready

      # This check is done after cloud-init so that it can create the file.
      while [ -e /root/patch-hold ]; do
          if [[ $count > $max_count ]]; then
              echo "Have waited max time of $max_count minutes so allowing patch to continue." 
              exit 0
          fi
          echo "Waiting 60s for /root/patch-hold to be removed."
          sleep 60
      done
DOC

  tags = {
    Environment = var.environment
  }
}

# Create the SSM association
resource "aws_ssm_association" "res_association" {
  name = "AWS-RunPatchBaselineWithHooks"

  targets {
    key    = "tag:res:EnvironmentName"
    values = var.res_environment_name # This will match the value for the res-environment
  }

  parameters = {
    PreInstallHookDocName = "wait-for-cloud-init"
    Operation             = "Scan"
    RebootOption          = "RebootIfNeeded"
  }

  # schedule_expression = "rate(30 minutes)" # Runs every 30 minutes

  # automation_target_parameter_name = "InstanceId"

  # compliance_severity = "MEDIUM"

  # max_concurrency = "50%"
  # max_errors      = "25%"

  tags = {
    Environment = var.environment
  }
}

resource "aws_ssm_association" "parallelcluster_association" {
  name = "AWS-RunPatchBaselineWithHooks"

  targets {
    key    = "tag:parallelcluster:node-type"
    values = ["Compute"] # This will match the value for the res-environment
  }

  parameters = {
    PreInstallHookDocName = "wait-for-cloud-init"
    Operation             = "Scan"
    RebootOption          = "NoReboot"
  }

  tags = {
    Environment = var.environment
  }
}
