#!/usr/bin/env python3
import json
import logging
import os
from pathlib import Path

import aws_cdk as cdk
import yaml
from yaml.loader import SafeLoader

from cdk_deploy_vpc.vpc_stack import VpcStack

# Add logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
# set logger to use date and time in the output

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.info("Starting CDK Stack")

# Not used currently
account_id = cdk.Aws.ACCOUNT_ID

app = cdk.App()
env = cdk.Environment(
    account=os.getenv("CDK_DEFAULT_ACCOUNT"), region=os.getenv("CDK_DEFAULT_REGION")
)

with open(os.path.join(Path(__file__).parent, "config.yml"), "r") as yaml_file:
    stack_config = yaml.load(yaml_file, Loader=SafeLoader)

network_ctx = app.node.try_get_context("network")
logger.info(f"Deploying network: '{network_ctx}'")
network_config = stack_config["networks"].get(network_ctx)
logger.info(f"Network Config: {network_config}")

if network_config is None:
    logger.error(
        f"Network '{network_ctx}' does not exist.  Please check cdk.json and try again..."
    )
    raise SystemExit(1)

vpc_stack = VpcStack(
    scope=app,
    stack_name=f"Networking-{network_config["name"]}",
    env=env,
    config=network_config,
)

# Tags are applied to all tagable resources in the stack
tags = app.node.try_get_context("tags")
if tags:
    for key, value in tags.items():
        cdk.Tags.of(vpc_stack).add(key=key, value=value)

# cdk.Tags.of(vpc_stack).add("ProjectName", config["ProjectName"])
cdk.Tags.of(vpc_stack).add("Environment", network_config["name"])

app.synth()
