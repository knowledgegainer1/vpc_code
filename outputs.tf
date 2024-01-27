output "azs_output" {
  value = data.aws_availability_zones.azs
}

output "public_subnet_id" {
  value = aws_subnet.public_sub[*].id
}
output "private_subnet_id" {
  value = aws_subnet.private_sub[*].id
}
output "database_subnet_id" {
  value = aws_subnet.database_sub[*].id
}

output "vpc_id" {
  value = aws_vpc.main.id
}