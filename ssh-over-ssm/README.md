# ssh-over-ssm

A CLI to connect to EC2 instances via SSM

## Pre-requisites

- AWS Account
- AWS CLI installed

## Getting Started

getting started details...

1. Generate SSH key

```bash
ssh-keygen -f ~/.ssh/id_rsa-ssm -N ''
```

2. Add the following to $HOME/.ssh/config

```
host i-* mi-*
  IdentityFile ~/.ssh/id_rsa-ssm
  User ec2-user
  ProxyCommand sh -c "/path/to/ssm-proxy.sh '%h' '%p' '%r'"
``

2.

## Usage

usage details...

## Build
```
