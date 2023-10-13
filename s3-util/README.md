# Empty S3 bucket

This project uses `boto3` to empty out all object versions from an S3 bucket, and optionally delete the bucket.

Pre-requisites

- AWS Account credentials
- Python3

# Getting Started

Add `empty-bucket` to **PATH**

example of adding to ~/.local/bin which is typically on **PATH**:

```bash
ln -s /path/to/checkout/empty-bucket ~/.local/bin/empty-bucket
```

# Usage

```
Usage: empty-bucket.py [OPTIONS]

  Deletes all objects in a bucket

Options:
  -b, --bucket TEXT  The bucket(s) you want to delete
  --delete           Delete the bucket(s)
  --help             Show this message and exit.
```

`empty-bucket -b <bucket_name> [--delete]`

## Examples

Deleting multiple buckets:

```bash
aws s3 ls | grep "open" | cut -d' ' -f3 | xargs -I{} empty-bucket -b {} --delete
```

# Build

```bash
# Create virtual environment
python3 -m venv .venv

# activate environment
source .venv/bin/activate

# install requirements
pip3 install -r requirements.txt
```
