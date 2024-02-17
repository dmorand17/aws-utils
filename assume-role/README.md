# Assume Role

This

Pre-requisites

- AWS Account credentials
- Python3

# Getting Started

run `install` to get started. The installation will add an alias to easily call the `assume-role` command

# Usage

```

```

Usage: empty-bucket.py [OPTIONS]

Deletes all objects in a bucket

Options:
-b, --bucket TEXT The bucket(s) you want to delete
--delete Delete the bucket(s)
--help Show this message and exit.

````

`empty-bucket -b <bucket_name> [--delete]`

## Examples

Assume a codebuild-flask-multi-arch role for 3600 seconds:

```bash
assume-role arn:aws:iam::${AWS_ACCOUNT_ID}:role/codebuild-flask-multi-arch 3600
````

# Build

```bash
# Create virtual environment
python3 -m venv .venv

# activate environment
source .venv/bin/activate

# install requirements
pip3 install -r requirements.txt
```
