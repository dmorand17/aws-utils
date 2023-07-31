# VPC with 2 public and 2 private subnets

This is a CloudFormation template that creates a VPC with 2 public and 2 private subnets.

## Prerequisites

- An AWS account
- AWS CLI installed and configured

## Usage

To create or update the stack, run the following command:

```bash
./deploy.sh <stack-name> <region>
```

Replace the parameters with the values you want to use. For example:

```bash
./deploy.sh my-vpc-stack us-east-1
```

To delete the stack, run the following command:

```bash
aws cloudformation delete-stack --stack-name <stack-name>
```

Replace <stack-name> with the name of the stack you want to delete.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
