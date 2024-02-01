# Find SSM Parameters

Simple utility to retrieve parameters from the SSM parameter store by a single region OR all regions.

## Getting Started

Add `ssm-parameters.sh` to **PATH**

example of adding to ~/.local/bin which is typically on **PATH**:

```bash
ln -s /path/to/checkout/ssm-parameters.sh ~/.local/bin/ssm-parameters
```

## Usage

```bash
❯ ssm-parameters
Usage: main.py [OPTIONS]

Options:
  -r, --region TEXT          Region to query  [default: (AWS_REGION)]
  -a, --all-regions          Query all regions
  -f, --format [table|json]  Output format  [default: json]
  -p, --path TEXT            Parameter path to query in SSM. e.g.
                             /aws/service/canonical/ubuntu  [required]
  -v, --verbose              Print debug messages
  --help                     Show this message and exit.
```

## Examples

Get a list of Ubuntu 22.04 AMIs for x86 arch

```bash
python3 ssm-parameters/main.py --recursive --all_regions -p /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64
```

_output_

```json
{
  "af-south-1": {
    "region_name": "af-south-1",
    "Parameters": []
  },
  "ap-east-1": {
    "region_name": "ap-east-1",
    "Parameters": []
  },
  "ap-northeast-1": {
    "region_name": "ap-northeast-1",
    "Parameters": [
      {
        "Name": "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id",
        "Value": "ami-06f25f372d5d98da3",
        "DataType": "aws:ec2:image"
      }
    ]
  },
  "ap-northeast-2": {
    "region_name": "ap-northeast-2",
    "Parameters": [
      {
        "Name": "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id",
        "Value": "ami-0610630c2df4f6edd",
        "DataType": "aws:ec2:image"
      }
    ]
  },
  "ap-northeast-3": {
    "region_name": "ap-northeast-3",
    "Parameters": [
      {
        "Name": "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id",
        "Value": "ami-02fdf18a7c3e8342a",
        "DataType": "aws:ec2:image"
      }
    ]
  },
  "ap-south-1": {
    "region_name": "ap-south-1",
    "Parameters": [
      {
        "Name": "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id",
        "Value": "ami-078bee86ac7c5ec2d",
        "DataType": "aws:ec2:image"
      }
    ]
  },
  "ap-south-2": {
    "region_name": "ap-south-2",
    "Parameters": []
  },
  "ap-southeast-1": {
    "region_name": "ap-southeast-1",
    "Parameters": [
      {
        "Name": "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id",
        "Value": "ami-081ab28ecb8f9f07f",
        "DataType": "aws:ec2:image"
      }
    ]
  },
  "ap-southeast-2": {
    "region_name": "ap-southeast-2",
    "Parameters": [
      {
        "Name": "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id",
        "Value": "ami-02e33cab84ad3b7e5",
        "DataType": "aws:ec2:image"
      }
    ]
  },
  "ap-southeast-3": {
    "region_name": "ap-southeast-3",
    "Parameters": []
  },
  "ap-southeast-4": {
    "region_name": "ap-southeast-4",
    "Parameters": []
  }
}
```

---

```bash
python3 ssm-parameters/main.py -v -f table -a -p /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64
```

_output_

```
╒════════════════╤════════════════════════════════════════════════════════════════════════════════════╤═══════════════╤═══════════════════════╕
│ region         │ name                                                                               │ datatype      │ value                 │
╞════════════════╪════════════════════════════════════════════════════════════════════════════════════╪═══════════════╪═══════════════════════╡
│ ap-northeast-1 │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-06f25f372d5d98da3 │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ ap-northeast-2 │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-0610630c2df4f6edd │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ ap-northeast-3 │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-02fdf18a7c3e8342a │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ ap-south-1     │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-078bee86ac7c5ec2d │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ ap-southeast-1 │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-081ab28ecb8f9f07f │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ ap-southeast-2 │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-02e33cab84ad3b7e5 │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ ca-central-1   │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-0d4b8b87818b26421 │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ eu-central-1   │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-0071fbe485985432e │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ eu-north-1     │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-0d534fbf90e256d14 │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ eu-west-1      │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-01b1f2cdbfcb3644e │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ eu-west-2      │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-0103fdca60001bd3c │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ eu-west-3      │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-0f2c91ec8df4bde48 │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ sa-east-1      │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-06142e9168d7fe5a9 │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ us-east-1      │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-0408adfcef670a71e │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ us-east-2      │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-004dae62019936191 │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ us-west-1      │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-035663315c4daae24 │
├────────────────┼────────────────────────────────────────────────────────────────────────────────────┼───────────────┼───────────────────────┤
│ us-west-2      │ /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id │ aws:ec2:image │ ami-0f1a3eb997d0e161a │
╘════════════════╧════════════════════════════════════════════════════════════════════════════════════╧═══════════════╧═══════════════════════╛
```

## Development

1/ Create a virtual environment

```bash
python3 -m venv .venv
source .venv/bin/activate
```

2/ Install requirements

```bash
pip install -r requirements.txt
```

## Manual testing

To test that the SSM path is correct, you can test against the AWS CLI (examples below).

```bash
# Get Amazon Linux 2 AMIs for ue1
aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --region us-east-1
aws ssm get-parameters-by-path --path "/aws/service/ami-amazon-linux-latest" --region us-east-1
```
