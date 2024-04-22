from aws_cdk import CfnOutput, Stack
from aws_cdk import aws_ec2 as ec2
from constructs import Construct


class VpcStack(Stack):
    def __init__(self, scope: Construct, stack_name: str, **kwargs) -> None:
        config = kwargs.pop("config")
        super().__init__(scope, stack_name, **kwargs)

        # The code that defines your stack goes here
        if config is None:
            raise ValueError("missing config!")

        vpc_cidr = config.get("vpc_cidr")
        vpc_name = config.get("name")

        # create the VPC
        vpc = ec2.Vpc(
            self,
            vpc_name,
            ip_addresses=ec2.IpAddresses.cidr(vpc_cidr),
            create_internet_gateway=True,
            max_azs=2,
            nat_gateways=1,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="public", subnet_type=ec2.SubnetType.PUBLIC, cidr_mask=24
                ),
                ec2.SubnetConfiguration(
                    name="private",
                    subnet_type=ec2.SubnetType.PRIVATE_WITH_EGRESS,
                    cidr_mask=22,
                ),
            ],
            gateway_endpoints={
                "S3": ec2.GatewayVpcEndpointOptions(
                    service=ec2.GatewayVpcEndpointAwsService.S3
                ),
                "DynamoDB": ec2.GatewayVpcEndpointOptions(
                    service=ec2.GatewayVpcEndpointAwsService.DYNAMODB
                ),
            },
        )

        if (
            config.get("ssm_endpoints") is not None
            and config.get("ssm_endpoints") is True
        ):
            # Add security grop
            sg = ec2.SecurityGroup(
                self,
                "ssm-endpoint-sg",
                vpc=vpc,
                allow_all_outbound=True,
            )

            # Add ssm endpoints to vpc
            vpc.add_interface_endpoint(
                "ssm-messages",
                service=ec2.InterfaceVpcEndpointAwsService.SSM_MESSAGES,
                security_groups=[sg],
            )
            vpc.add_interface_endpoint(
                "ssm",
                service=ec2.InterfaceVpcEndpointAwsService.SSM,
                security_groups=[sg],
            )

        # Output vpc details
        # print the IAM role arn for this service account
        CfnOutput(
            self, "VpcId", value=vpc.vpc_id, export_name=f"{self.stack_name}-VpcId"
        )

        # Add the subnets to the output
        CfnOutput(
            self,
            "PublicSubnets",
            value=", ".join(map(lambda subnet: subnet.subnet_id, vpc.public_subnets)),
            export_name=f"{self.stack_name}-PublicSubnets",
        )

        CfnOutput(
            self,
            "PrivateSubnets",
            value=", ".join(map(lambda subnet: subnet.subnet_id, vpc.private_subnets)),
            export_name=f"{self.stack_name}-PrivateSubnets",
        )
