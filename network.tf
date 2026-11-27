data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = {
    owner       = var.owner
    environment = var.environment
  }
}

# Private-only VPC: no internet gateway, no NAT, no public subnets.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for i, _ in local.azs : cidrsubnet(var.vpc_cidr, 8, i)]

  enable_nat_gateway      = false
  map_public_ip_on_launch = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Lock down the default security group (no ingress, no egress).
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # VPC flow logs to an encrypted CloudWatch log group.
  enable_flow_log                                 = true
  create_flow_log_cloudwatch_log_group            = true
  create_flow_log_cloudwatch_iam_role             = true
  flow_log_max_aggregation_interval               = 60
  flow_log_cloudwatch_log_group_retention_in_days = var.log_retention_in_days
  flow_log_cloudwatch_log_group_kms_key_id        = aws_kms_key.stack.arn

  tags = local.common_tags
}
