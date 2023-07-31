import boto3
import json
import uuid

kinesis = boto3.client("kinesis")


def lambda_handler(event, context):
    stream_name = event["stream_name"]
    data = event["data"]
    partition_key = event.get("partition_key", str(uuid.uuid4()))

    payload = json.dumps(data)

    response = kinesis.put_record(
        StreamName=stream_name, Data=payload, PartitionKey=partition_key
    )

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": f'Record put into {stream_name} with sequence number {response["SequenceNumber"]}'
            }
        ),
    }
