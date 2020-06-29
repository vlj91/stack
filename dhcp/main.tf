variable "vpc_id" {
  description = "VPC ID to deploy the cluster into"
  type        = string  
}

variable "dns_zone_name" {
  type        = string
  description = "Route53 DNS zone name"
}

variable "name_servers" {
  type        = list(string)
  description = "List of internal DHCP servers"
}

resource "aws_vpc_dhcp_options" "resolver" {
  domain_name         = var.dns_zone_name
  domain_name_servers = var.name_servers
}

resource "aws_vpc_dhcp_options_association" "resolver" {
  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.resolver.id
}