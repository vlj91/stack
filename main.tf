variable "name" {
  description = "Name of the stack/cluster"
  default     = "stack"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to resources"
  default    = {}
  type       = map(string)
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