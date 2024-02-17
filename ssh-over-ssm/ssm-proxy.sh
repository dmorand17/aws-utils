#!/bin/bash

# Add the following to $HOME/.ssh/config
#   host i-* mi-*
#   ProxyCommand sh -c "/path/to/ssm-proxy.sh '%h' '%p' '%r'"
# 

# Then you can SSH-via-SessionManager using a command like this:
# ssh ec2-user@i-07e9bd6d3497545cd,eu-west-2
# SCP works too:
# scp ec2-user@i-07e9bd6d3497545cd,eu-west-2:.bash_history history

set -eou pipefail

SSH_HOME=$HOME/.ssh
