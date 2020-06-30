variable "stack_name" {
  description = "Stack name"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones to deploy into"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  vpc   = true

  tags  = merge(var.tags, {
    "kubernetes.io/cluster.name" = var.stack_name
  })
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.stack_name
  cidr   = "10.0.0.0/16"
  azs    = var.availability_zones

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = true

  reuse_nat_ips       = true
  external_nat_ip_ids = aws_eip.nat.*.id

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  database_subnets = [
    "10.0.21.0/24",
    "10.0.22.0/24",
    "10.0.23.0/24"
  ]

  elasticache_subnets = [
    "10.0.31.0/24",
    "10.0.32.0/24",
    "10.0.33.0/24"
  ]

  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]

  tags = {
    "kubernetes.io/cluster/${var.stack_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}


output "cluster_subnets" {
  value = setunion(module.vpc.public_subnets, module.vpc.private_subnets)
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_cidr_block" {
  value = module.vpc.default_vpc_cidr_block
}
