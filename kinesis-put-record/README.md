# Kinesis Stream Record Putter

This project includes two scripts for putting records into an AWS Kinesis stream:

- `put_records.sh` (Bash)
- `put_records.py` (Python)

## Requirements

- AWS CLI installed and configured with your AWS credentials.
- An existing Kinesis stream

## Usage

### Bash Script

The `put_records.sh` script allows you to put a JSON record into a Kinesis stream.

#### Usage

```bash
./put_records.sh <data> [stream_name] [partition_key]
```

- `data` (required): The JSON data to put into the stream. It can be passed as a plain string or a path to a file containing the JSON data.
- `stream_name` (optional): The name of the Kinesis stream to put the record into. If not specified, it will be read from the `KINESIS_STREAM_NAME` environment variable.
- `partition_key` (optional): The partition key to use for the record. If not specified, a UUID will be generated.

#### Examples

Put a JSON record into a stream:

```bash
./put_records.sh my-kinesis-stream "{'id': 123, 'name': 'John Doe'}" user_123
```

Put a JSON record from a file into a stream:

```bash
./put_records.sh my-kinesis-stream ./record.json user_123
```

### Python Script

The `put_records.py` script allows you to put a JSON record into a Kinesis stream using Python.

#### Usage

```bash
python put_records.py [--stream-name STREAM_NAME] [--partition-key PARTITION_KEY] data
```

- `--stream-name` (optional): The name of the Kinesis stream to put the record into. If not specified, it will be read from the `KINESIS_STREAM_NAME` environment variable.
- `--partition-key` (optional): The partition key to use for the record. If not specified, a UUID will be generated.
- `data` (required): The JSON data to put into the stream. It can be passed as a plain string or a path to a file containing the JSON data.

#### Examples

Put a JSON record into a stream:

```bash
python put_records.py "{'id': 123, 'name': 'John Doe'}" --stream-name my-kinesis-stream --partition-key user_123
```

Put a JSON record from a file into a stream:

```bash
python put_records.py ./record.json --stream-name my-kinesis-stream --partition-key user_123
```
