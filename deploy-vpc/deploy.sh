#!/bin/bash

set -ou pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") stack-name region [aws-cli-opts]

Options:
  stack-name   - the stack name
  region       - region to deploy stack
  aws-cli-opts - extra options passed to create/update stack
EOF
}

if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "help" ]; then
  usage
  exit 1
fi

# Replace these values with your own
STACK_NAME="$1"
REGION="$2"
# REGION=${AWS_REGION:-"us-east-1"}
VPC_CIDR_BLOCK="10.0.0.0/16"
PUBLIC_SUBNET1_CIDR_BLOCK="10.0.1.0/24"
PUBLIC_SUBNET2_CIDR_BLOCK="10.0.2.0/24"
PRIVATE_SUBNET1_CIDR_BLOCK="10.0.3.0/24"
PRIVATE_SUBNET2_CIDR_BLOCK="10.0.4.0/24"

# Check if the stack already exists
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION >/dev/null 2>&1; then
  echo "Stack already exists, updating..."
  # Update the CloudFormation stack
  aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --template-body file://vpc-template.yaml \
    --parameters \
        ParameterKey=VpcCidrBlock,ParameterValue=$VPC_CIDR_BLOCK \
        ParameterKey=PublicSubnet1CidrBlock,ParameterValue=$PUBLIC_SUBNET1_CIDR_BLOCK \
        ParameterKey=PublicSubnet2CidrBlock,ParameterValue=$PUBLIC_SUBNET2_CIDR_BLOCK \
        ParameterKey=PrivateSubnet1CidrBlock,ParameterValue=$PRIVATE_SUBNET1_CIDR_BLOCK \
        ParameterKey=PrivateSubnet2CidrBlock,ParameterValue=$PRIVATE_SUBNET2_CIDR_BLOCK \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION
  # Wait for the CloudFormation stack to be updated
  aws cloudformation wait stack-update-complete --stack-name $STACK_NAME --region $REGION
else
  echo "Stack does not exist, creating..."
  # Validate the CloudFormation template
  aws cloudformation validate-template --template-body file://vpc-template.yaml --region $REGION
  # Create the CloudFormation stack
  aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://vpc-template.yaml \
    --parameters \
        ParameterKey=VpcCidrBlock,ParameterValue=$VPC_CIDR_BLOCK \
        ParameterKey=PublicSubnet1CidrBlock,ParameterValue=$PUBLIC_SUBNET1_CIDR_BLOCK \
        ParameterKey=PublicSubnet2CidrBlock,ParameterValue=$PUBLIC_SUBNET2_CIDR_BLOCK \
        ParameterKey=PrivateSubnet1CidrBlock,ParameterValue=$PRIVATE_SUBNET1_CIDR_BLOCK \
        ParameterKey=PrivateSubnet2CidrBlock,ParameterValue=$PRIVATE_SUBNET2_CIDR_BLOCK \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION
  # Wait for the CloudFormation stack to be created
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION
fi

# Print the CloudFormation stack outputs
aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].Outputs'
