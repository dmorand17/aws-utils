import aws_cdk as core
import aws_cdk.assertions as assertions

from cdk_deploy_vpc.cdk_deploy_vpc_stack import CdkDeployVpcStack

# example tests. To run these tests, uncomment this file along with the example
# resource in cdk_deploy_vpc/cdk_deploy_vpc_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = CdkDeployVpcStack(app, "cdk-deploy-vpc")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
