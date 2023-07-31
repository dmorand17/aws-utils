import boto3
import json
import argparse
import os
import uuid

parser = argparse.ArgumentParser(description="Put records into a Kinesis stream")
parser.add_argument("data", type=str, help="JSON data to put into the stream")
parser.add_argument(
    "--partition-key",
    type=str,
    help="Partition key to use for the record (default: UUID)",
)
parser.add_argument(
    "--stream-name",
    type=str,
    default=os.environ.get("KINESIS_STREAM_NAME"),
    help="Name of the Kinesis stream",
)
args = parser.parse_args()

if not args.stream_name or not args.data:
    parser.print_usage()
    exit(1)

kinesis = boto3.client("kinesis")

try:
    data = json.loads(args.data)
except ValueError:
    with open(args.data) as f:
        data = json.load(f)

partition_key = args.partition_key or str(uuid.uuid4())
payload = json.dumps(data)

response = kinesis.put_record(
    StreamName=args.stream_name, Data=payload, PartitionKey=partition_key
)

print(
    f"Record put into {args.stream_name} with sequence number {response['SequenceNumber']}"
)
