data "aws_availability_zones" "current" {}

output "availability_zones" {
  value = data.aws_availability_zones.current.names
}