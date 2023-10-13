#!/bin/bash

# Uncomment to enable debugging
# set -x

data="$1"
stream_name="${KINESIS_STREAM_NAME:-$2}"
partition_key="${3:-default}"

if [ -z "$stream_name" ] || [ -z "$data" ]; then
    echo "Usage: $0 <data> [stream_name] [partition_key]" >&2
    exit 1
fi

aws kinesis put-record \
--stream-name "$stream_name" \
--data file://"$data"  \
--partition-key "$partition_key" \
--cli-binary-format raw-in-base64-out
