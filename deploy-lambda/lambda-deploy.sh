#!/bin/bash

set -ou pipefail

usage() {
    cat <<EOF
lambda-deploy.sh

Description: Upserts a lambda function
Usage: lambda-deploy.sh -n <name> -d <lambda_directory> [--layer]

Environment variables:
    ZIP_FILE                    Lambda zipfile (defaults to 'lambda-package.zip')
    LAMBDA_RUNTIME              Lambda runtime (defaults to 'python3.9')

Options:
    -n <name>                   Name of a function or layer e.g. 'MyFunction'
    -d <lambda_directory>       Lambda Directory (defaults to current directory if not supplied)
    --layer                     Publish layer

Examples:
    lambda-deploy.sh -n MyFunction -d ~/workspace/projects/lambda-function
EOF
}

exe() { echo "\$ $*" ; "$@" ; }

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Environment Variables 
ZIP_FILE="${ZIP_FILE:-lambda-package.zip}"
LAMBDA_RUNTIME="${LAMBDA_RUNTIME:-python3.9}"
LAMBDA_DIRECTORY=$(pwd)
LAYER=false

while [ "$#" -gt 0 ]; do
    case $1 in
    (-n)  LAMBDA_NAME=$2
          shift 2
          ;;

    (-d)  LAMBDA_DIRECTORY=$2
          shift 2
          ;;

    (--layer)   LAYER=true
                shift
                ;;
    (--)  shift
          break
          ;;

    (-*)  echo "unknown option: $1"
          return 1
          ;;

    (*)   break
          ;;
    esac    
done


SCRIPT_DIR=$(dirname "$0")
# pushd "$SCRIPT_DIR" &> /dev/null

if [[ ! -d "${LAMBDA_DIRECTORY}" ]]; then
    echo "${LAMBDA_DIRECTORY} does not exist!"
    exit 1
fi

echo "🛠  Packaging Lambda..."
pushd "${LAMBDA_DIRECTORY}" &> /dev/null

if [[ -f "requirements.txt" ]]; then
    rm -rf package && mkdir package
    echo -e "✏️  Installing dependencies...\n"
    pip3 install --target ./package -r requirements.txt  
    cd package && zip -r ../"${ZIP_FILE}" . && cd -
    rm -rf package
fi

# Add lambda_function.py to package
zip -g "${ZIP_FILE}" lambda_function.py
printf "\nPackage: ${GREEN}${ZIP_FILE}${NC} created...\n"

if [[ "${LAYER}" = true ]]; then
    # Deploy Lambda Layer
    exe aws lambda publish-layer-version \
    --layer-name "${LAMBDA_NAME}" \
    --description "Lambda Layer Description" \
    --compatible-runtimes "${LAMBDA_RUNTIME}" \
    --zip-file "fileb://${ZIP_FILE}" "$@"    
else
    # Deploy Lambda Function
    # Check if lambda function exists
    aws lambda get-function --function-name "${LAMBDA_NAME}" &> /dev/null

    # Deploy function
    if [[ 0 -eq  $? ]]; then
        echo "Updating '${LAMBDA_NAME}'..."
        exe aws lambda update-function-code \
        --function-name "${LAMBDA_NAME}" \
        --zip-file "fileb://${ZIP_FILE}" "$@"
    else
        echo "Creating '${LAMBDA_NAME}'..."
        ROLE_ID=$(aws iam get-role --role-name "${LAMBDA_NAME}"-role | jq -r '.Role.Arn')
        if [[ 0 -eq $? ]]; then
            echo "Role '${LAMBDA_NAME}-role' already exists..."
        else
            echo "Creating '${LAMBDA_NAME}-role' IAM role"
            ROLE_ID=$(aws iam create-role --role-name "${LAMBDA_NAME}"-role --assume-role-policy-document file://"${SCRIPT_DIR}"/lambda-role.json | jq -r '.Role.Arn')
            echo "📝  Role '${ROLE_ID}' created"
        fi 

        exe aws lambda create-function \
        --role "${ROLE_ID}" \
        --function-name "${LAMBDA_NAME}" \
        --runtime "${LAMBDA_RUNTIME}" \
        --handler lambda_function.lambda_handler \
        --zip-file "fileb://${ZIP_FILE}" "$@"
    fi
fi

echo "✨  Finished!"
popd &> /dev/null
