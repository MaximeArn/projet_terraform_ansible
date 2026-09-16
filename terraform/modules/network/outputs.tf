output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "IDs of the application private subnets."
  value       = aws_subnet.app[*].id
}

output "data_subnet_ids" {
  description = "IDs of the data private subnets."
  value       = aws_subnet.data[*].id
}
