#!/usr/bin/env python
import boto3
import click

# sts = boto3.client('sts')
# print(sts.get_caller_identity())

s3 = boto3.resource("s3")


@click.command(no_args_is_help=True)
@click.option(
    "--bucket",
    "-b",
    multiple=True,
    help="The bucket(s) you want to empty",
)
@click.option(
    "--delete",
    is_flag=True,
    show_default=True,
    default=False,
    help="Delete the bucket(s)",
)
def empty_bucket(bucket, delete):
    """
    Delete all object versions in a bucket.  Optionally delete bucket
    """
    for idx, bucket_name in enumerate(bucket, 1):
        print(f"[-] Emptying bucket '{bucket_name}' ...")
        bucket = s3.Bucket(bucket_name)
        bucket.object_versions.delete()
        print(f"[✔] Emptied '{bucket_name}'")
        if delete:
            bucket.delete()
            print(f"[✔] Bucket '{bucket_name}' deleted")


if __name__ == "__main__":
    empty_bucket()
