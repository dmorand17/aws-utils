#!/usr/bin/env python3
import logging
import os

import aws_cdk as cdk

from cdk_deploy_vpc.cdk_deploy_vpc_stack import CdkDeployVpcStack

# Add logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.info("Starting CDK Stack")

# Not used currently
account_id = cdk.Aws.ACCOUNT_ID

app = cdk.App()

globals = app.node.try_get_context("globals")
if globals is None:
    logger.error("No globals specified. Exiting.")
    raise SystemExit(1)

environments = app.node.try_get_context("environments")

env = app.node.try_get_context("config")
config = None
if env and environments[env]:
    config = environments[env]
    if config is None:
        logger.error("No environment specified. Exiting.")
        raise SystemExit(1)

print(f"{os.environ.get('CDK_DEPLOY_ACCOUNT')}")

CdkDeployVpcStack(
    app,
    "CdkVPC",
    env=cdk.Environment(
        account=os.environ.get("CDK_DEPLOY_ACCOUNT", os.environ["CDK_DEFAULT_ACCOUNT"]),
        region=os.environ.get("CDK_DEPLOY_REGION", os.environ["CDK_DEFAULT_REGION"]),
    ),
    config=config
    # If you don't specify 'env', this stack will be environment-agnostic.
    # Account/Region-dependent features and context lookups will not work,
    # but a single synthesized template can be deployed anywhere.
    # Uncomment the next line to specialize this stack for the AWS Account
    # and Region that are implied by the current CLI configuration.
    # env=cdk.Environment(account=os.getenv('CDK_DEFAULT_ACCOUNT'), region=os.getenv('CDK_DEFAULT_REGION')),
    # Uncomment the next line if you know exactly what Account and Region you
    # want to deploy the stack to. */
    # env=cdk.Environment(account='123456789012', region='us-east-1'),
    # For more information, see https://docs.aws.amazon.com/cdk/latest/guide/environments.html
)

# Tags are applied to all tagable resources in the stack
# if config["Tags"]:
#     for key, value in config["Tags"].items():
#         cdk.Tags.of(nsaph_stack).add(key=key, value=value)
#         # cdk.Tag.add(scope=main_app, key=key, value=value)

# cdk.Tags.of(nsaph_stack).add("ProjectName", config["ProjectName"])
# cdk.Tags.of(nsaph_stack).add("Environment", config["Environment"])

app.synth()
