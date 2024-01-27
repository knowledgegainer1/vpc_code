locals {
  name="${var.project}_${var.environment}"
  azs=slice(data.aws_availability_zones.azs.names,0,2)
}