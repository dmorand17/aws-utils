#!/usr/bin/env python
import boto3
import botocore
import click

# sts = boto3.client('sts')
# print(sts.get_caller_identity())

s3 = boto3.resource("s3")


@click.group()
@click.option("--verbose", default=False)
@click.option(
    "--bucket",
    "-b",
    "buckets",
    multiple=True,
    required=True,
    help="The bucket(s) you want to interact with",
)
@click.pass_context
def cli(ctx, buckets, verbose):
    # ensure that ctx.obj exists and is a dict (in case `cli()` is called
    # by means other than the `if __name__ == '__main__'` block below)
    # ctx.ensure_object(dict)
    ctx.obj["verbose"] = verbose
    ctx.obj["buckets"] = buckets
    # print(f"{ctx.obj=}")
    pass


# @click.command(no_args_is_help=True)
@cli.command("empty")
@click.option(
    "--delete",
    is_flag=True,
    show_default=True,
    default=False,
    help="Delete the bucket(s)",
)
@click.pass_context
def empty_bucket(ctx, delete):
    """
    Delete all object versions in a bucket.  Optionally delete bucket
    """
    # print(f"context: {ctx.obj}\n")
    buckets = ctx.obj["buckets"]
    for idx, bucket_name in enumerate(buckets, 1):
        print(f"[-] Emptying bucket '{bucket_name}' ...")
        try:
            bucket = s3.Bucket(bucket_name)
            bucket.object_versions.delete()
            print(f"[✔] Emptied '{bucket_name}'")
            if delete:
                result = ctx.invoke(delete_bucket)
                # print(f"{result=}")
        except Exception as e:
            print(f"[!] An error occurred while emptying '{bucket_name}'\n{e}")


@cli.command("delete")
@click.pass_context
@click.confirmation_option(prompt="Are you sure you want to delete the bucket?")
def delete_bucket(ctx):
    """
    Delete s3 bucket
    """
    buckets = ctx.obj["buckets"]
    # print(f"{buckets=}")
    try:
        for bucket_name in buckets:
            bucket = s3.Bucket(bucket_name)
            bucket.delete()
            print(f"[✔] Bucket '{bucket_name}' deleted")
    except Exception as e:
        print(f"[!] An error occurred while deleting'{bucket_name}'\n{e}")

    return "Done!"


if __name__ == "__main__":
    cli(obj={})
