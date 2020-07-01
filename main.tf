variable "name" {
  description = "Name of the stack/cluster"
  default     = "stack"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to resources"
  default     = {}
  type        = map(string)
}

module "defaults" {
  source = "./defaults"
}

module "vpc" {
  source = "./vpc"

  stack_name         = var.name
  availability_zones = module.defaults.availability_zones
}

module "dns" {
  source = "./dns"

  stack_name = var.name
  vpc_id     = module.vpc.vpc_id
  tags       = var.tags
}

module "cluster" {
  source = "./cluster"

  stack_name = var.name
  aws_region = module.defaults.aws_region
  subnet_ids = module.vpc.cluster_subnets
  vpc_id     = module.vpc.vpc_id
}

module "compute" {
  source = "./compute/eks-managed"

  stack_name = module.cluster.name
  subnet_ids = module.vpc.private_subnets
}

output "kubeconfig" {
  value = module.cluster.kubeconfig
}

output "kubernetes_version" {
  value = module.cluster.cluster_version
}

output "name" {
  value = module.cluster.name
}

output "providers" {
  value = module.cluster.providers
}

output "cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}

output "cluster_certificate" {
  value = module.cluster.cluster_certificate
}

output "oidc_issuer" {
  value = module.cluster.oidc_issuer
}