data "aws_availability_zones" "current" {}

output "availability_zones" {
  value = data.aws_availability_zones.current.names
}

data "aws_region" "current" {}

output "aws_region" {
  value = data.aws_region.current.name
}