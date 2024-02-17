from aws_cdk import CfnOutput, Stack
from aws_cdk import aws_ec2 as ec2
from constructs import Construct


class CdkDeployVpcStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        config = kwargs.pop("config")
        super().__init__(scope, construct_id, **kwargs)

        # The code that defines your stack goes here
        if config is None:
            raise ValueError("missing config!")

        vpc_cidr = config.get("vpc_cidr")
        vpc_name = config.get("name")

        # create the VPC
        vpc = ec2.Vpc(
            self,
            vpc_name,
            cidr=vpc_cidr,
            max_azs=2,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="public1", subnet_type=ec2.SubnetType.PUBLIC, cidr_mask=24
                ),
                ec2.SubnetConfiguration(
                    name="private1",
                    subnet_type=ec2.SubnetType.PRIVATE_WITH_EGRESS,
                    cidr_mask=24,
                ),
            ],
            gateway_endpoints={
                "S3": ec2.GatewayVpcEndpointOptions(
                    service=ec2.GatewayVpcEndpointAwsService.S3
                )
            },
            nat_gateways=1,
        )

        # Output vpc details
        # print the IAM role arn for this service account
        CfnOutput(
            self, "VpcId", value=vpc.vpc_id, export_name=f"{self.stack_name}-VPCID"
        )
