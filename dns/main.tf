variable "vpc_id" {
  description = "VPC ID used to create the private zone"
  type        = string
}

variable "dns_name_suffix_internal" {
  description = "Cluster internal zone suffix"
  type        = string
  default     = "cluster.local"
}

variable "stack_name" {
  description = "Stack name"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

resource "aws_route53_zone" "internal" {
  name    = "${var.stack_name}.${var.dns_name_suffix_internal}"
  vpc_id  = var.vpc_id
  comment = "${var.stack_name} internal zone"
}

output "internal_zone_name" {
  description = "Internal DNS zone name"
  value       = "${var.stack_name}.${var.dns_name_suffix_internal}"
}

output "internal_zone_id" {
  description = "Internal DNS zone ID"
  value      = aws_route53_zone.internal.zone_id
}

output "internal_zone_name_servers" {
  description = "Internal DNS zone name servers"
  value       = aws_route53_zone.internal.name_servers
}