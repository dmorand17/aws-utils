#!/bin/bash

set -ou pipefail

usage() {
    cat <<EOF
create-or-update-stack.sh

Description: Create or Update a CloudFormation stack
Usage: $(basename "$0") -n <name> -d <lambda_directory> [--layer]

Environment variables:
    ZIP_FILE                    Lambda zipfile (defaults to 'lambda-package.zip')
    LAMBDA_RUNTIME              Lambda runtime (defaults to 'python3.9')

Options:
    -n <name>                   Name of a function or layer e.g. 'MyFunction'
    -d <lambda_directory>       Lambda Directory (defaults to current directory if not supplied)
    --layer                     Publish layer

Examples:
    create-or-update-stack.sh -n MyFunction -d ~/workspace/projects/lambda-function

Usage: $(basename "$0") stack-name [aws-cli-opts]

Options:
  stack-name   - the stack name
  aws-cli-opts - extra options passed directly to create-stack/update-stack    
EOF
}

usage="Usage: $(basename "$0") stack-name [aws-cli-opts]
      
      Options:
        stack-name   - the stack name
        aws-cli-opts - extra options passed directly to create-stack/update-stack
"


if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "help" ]; then
  usage
  exit 1
fi

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ; then
  echo "$usage"
  exit 1
fi

echo "Checking if stack exists ..."

AWS_REGION=${AWS_REGION:-$1}
# AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-$1}
STACK_NAME=${STACK_NAME:-$1}

if ! aws cloudformation describe-stacks --region $REGION --stack-name $2 ; then

  echo -e "\nStack does not exist, creating ..."
  aws cloudformation create-stack \
    --region $1 \
    --stack-name $2 \
    ${@:3}

  echo "Waiting for stack to be created ..."
  aws cloudformation wait stack-create-complete \
    --region $1 \
    --stack-name $2 \
else
  echo -e "\nStack exists, updating ..."

  set +e
  update_output=$(aws cloudformation update-stack \
    --region $1 \
    --stack-name $2 \
    ${@:3}  2>&1)
  status=$?
  set -e

  echo "$update_output"

  if [ $status -ne 0 ] ; then

    # Don't fail for no-op update
    if [[ $update_output == *"ValidationError"* && $update_output == *"No updates"* ]] ; then
      echo -e "\nFinished create/update - no updates to be performed"
      exit 0
    else
      exit $status
    fi

  fi

  echo "Waiting for stack update to complete ..."
  aws cloudformation wait stack-update-complete \
    --region $1 \
    --stack-name $2 \
fi

echo "Finished create/update successfully!"
