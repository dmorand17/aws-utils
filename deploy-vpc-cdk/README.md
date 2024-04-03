# cdk-deploy-vpc

Deploy a VPC using public/private subnets via the CDK

## Prerequisites

- An AWS account
- AWS CLI installed and configured

## Getting Started

### CDK

Steps involved in launching CDK

- Bootstrapping: https://docs.aws.amazon.com/cdk/v2/guide/bootstrapping.html
- Getting started: https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html

```bash
# Install CDK
npm install -g aws-cdk

# Bootstrap CDK
cdk bootstrap aws://ACCOUNT-NUMBER-1/REGION-1

# Init CDK python app
cdk init app --language python
```

Activate the python virtual environment

```bash
source .venv/bin/activate
python -m pip install -r requirements.txt
```

```bash
./cdk-deploy-to.sh 872771682304 us-east-1 -c config=isengard-sandbox
```

```bash
cdk deploy --context network=sandbox
cdk destroy --context network=sandbox

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```
