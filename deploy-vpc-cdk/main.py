import argparse
from aws_cdk import aws_ec2 as ec2, core


class MyStack(core.Stack):
    def __init__(self, scope: core.Construct, id: str, vpc_cidr: str, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)

        # create the VPC
        vpc = ec2.Vpc(
            self,
            "MyVPC",
            cidr=vpc_cidr,
            max_azs=2,
            subnet_configuration=[
                ec2.SubnetConfiguration(
                    name="public", subnet_type=ec2.SubnetType.PUBLIC, cidr_mask=24
                ),
                ec2.SubnetConfiguration(
                    name="private", subnet_type=ec2.SubnetType.PRIVATE, cidr_mask=24
                ),
            ],
            nat_gateways=1,
        )

        # print the IDs of the created subnets
        for subnet in vpc.private_subnets:
            print(subnet.subnet_id)
        for subnet in vpc.public_subnets:
            print(subnet.subnet_id)


if __name__ == "main":
    parser = argparse.ArgumentParser(description="Create a VPC")
    parser.add_argument("stack_name", help="Stack name")
    parser.add_argument("vpc_cidr", help="CIDR block for the VPC")
    args = parser.parse_args()

    app = core.App()
    MyStack(app, args.stack_name, args.vpc_cidr)
    app.synth()
