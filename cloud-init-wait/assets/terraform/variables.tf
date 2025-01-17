
variable "region" {
  description = "AWS region for resource creation"
  type        = string
  default     = "us-east-1"
}

variable "aws_account" {
  description = "AWS account ID for resource tagging"
  type        = string
}

variable "res_environment_name" {
  description = "The tag value used for res:Environment"
  # type is a list of strings
  type    = list(string)
  default = ["res-demo"]
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "dev"
}
