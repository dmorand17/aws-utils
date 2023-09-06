#!/bin/bash

set -ou pipefail

# Set the AMI pattern
AMI_PATTERN=${1:-/al2023-ami-kernel-default-x86_64}

AWS_REGIONS=$(aws ssm get-parameters-by-path \
    --path /aws/service/global-infrastructure/services/ssm/regions \
    --query 'Parameters' | jq -r 'sort_by(.Value) | .[].Value')

# Declare a string array for regions
#RegionArray=("af-south-1" "ap-east-1" "ap-northeast-1" "ap-northeast-2" "ap-northeast-3" "ap-south-1" "ap-south-2" "ap-southeast-1" "ap-southeast-2" "ap-southeast-3" "ap-southeast-4" "ca-central-1" "eu-central-1" "eu-central-2" "eu-north-1" "eu-south-1" "eu-south-2" "eu-west-1" "eu-west-2" "eu-west-3" "me-central-1" "me-south-1" "sa-east-1" "us-east-1" "us-east-2" "us-west-1" "us-west-2")

# Find the linux ami by region
echo "[i] Searching for AMI pattern '${AMI_PATTERN}'"
echo 
printf "%-15s | %-10s\n" "AWS_REGION" "AMI_ID"
printf "%-15s | %-10s\n" "----------" "----------"
for region in ${AWS_REGIONS[*]}; do
  
  #echo  -n "[-] ${region} | "
  AMI_ID=$(aws ssm get-parameters-by-path --path "/aws/service/ami-amazon-linux-latest/" --region "${region}" 2> /dev/null | jq -r '.Parameters[] | select(.Name=="/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64") | .Value')
  if [ $? -eq 0 ]; then
    printf "%-15s | %-10s\n" "${region}" "${AMI_ID}"
    #echo "[+] Found AMI in ${region}"
  else
    printf "%-15s | %-10s\n" "${region}" "NOT FOUND"
    #echo "[-] AMI not found in ${region}"
  fi
done
