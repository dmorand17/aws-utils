#!/usr/bin/env bash

# Put into .ssh/config like this:
# host i-* mi-*
# ProxyCommand sh -c "/path/to/ssm-ssh-thunk.sh '%r' '%h' '%p'"
#
# Then you can SSH-via-SessionManager using a command like this:
# ssh ec2-user@i-07e9bd6d3497545cd,eu-west-2
# SCP works too:
# scp ec2-user@i-07e9bd6d3497545cd,eu-west-2:.bash_history history
#
# Works on instances that have both amazon-ssm-agent and ec2-instance-connect installed (e.g. any recent Amazon Linux).
# Credentials for AWS supplied in the normal fashion (environment variables, ~/.aws/credentials, etc.)

set -e

user="$1"
target="$2"
port="$3"

if [[ "${target}" =~ (m?i-[0-9a-f]+)(,([a-z0-9-]+))? ]]; then
  instance_id="${BASH_REMATCH[1]}"
  [[ "${BASH_REMATCH[3]}" != "" ]] && export AWS_DEFAULT_REGION="${BASH_REMATCH[3]}"
else
  echo >&2 "Could not parse: ${target}"
  exit 1
fi

echo >&2 "$(tput setaf 5)get instance details$(tput setaf 7)"
# Look up the AZ of the instance
az="$( aws ec2 describe-instances --instance-id "${instance_id}" | jq -r '.Reservations[0].Instances[0].Placement.AvailabilityZone' )"

# Locate an SSH public key
for file in ~/.ssh/id_rsa.pub ~/.ssh/id_dsa.pub; do
  if [ -f "${file}" ]; then
    echo >&2 "$(tput setaf 5)add ephemeral key$(tput setaf 7)"
    aws ec2-instance-connect send-ssh-public-key \
    --instance-id "${instance_id}" \
    --availability-zone "${az}" \
    --instance-os-user "${user}" \
    --ssh-public-key "file://${file}"
    break
  fi
done

echo >&2 "$(tput setaf 5)start session$(tput setaf 7)"
exec aws ssm start-session --target "${instance_id}" --document-name AWS-StartSSHSession --parameters portNumber="${port}"
