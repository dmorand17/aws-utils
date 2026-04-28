# s3-purge

Empties all object versions from one or more S3 buckets and optionally deletes them.

## Pre-requisites

- AWS Account credentials
- Python 3
- [`uv`](https://docs.astral.sh/uv/)

## Getting Started

Add `s3-purge` to **PATH**

Example using `~/.local/bin`, which is typically on **PATH**:

```bash
ln -s "$(pwd)/s3-purge" ~/.local/bin/s3-purge
```

## Usage

```
Usage: s3-purge [OPTIONS] COMMAND [ARGS]...

Options:
  -b, --bucket TEXT  The bucket(s) you want to interact with  [required]
  --verbose
  --help             Show this message and exit.

Commands:
  delete  Delete s3 bucket
  empty   Delete all object versions in a bucket. Optionally delete bucket
```

### Examples

Empty a bucket:

```bash
s3-purge -b <bucket_name> empty
```

Empty and delete a bucket:

```bash
s3-purge -b <bucket_name> empty --delete
```

Empty and delete multiple buckets:

```bash
aws s3 ls | grep "open" | cut -d' ' -f3 | xargs -I{} s3-purge -b {} empty --delete
```

## Build

Dependencies are managed via `pyproject.toml`. `uv run` handles the virtual environment automatically on first use.
