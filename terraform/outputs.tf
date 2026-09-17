output "environment" {
  description = "Deployment environment."
  value       = var.environment
}
output "vpc_id" {
  description = "ID of the project VPC."
  value       = module.network.vpc_id
}
output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.network.public_subnet_ids
}
output "private_subnet_ids" {
  description = "IDs of the private application subnets."
  value       = module.network.private_subnet_ids
}
output "database_subnet_ids" {
  description = "IDs of the database subnets."
  value       = module.network.database_subnet_ids
}
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer — the application endpoint."
  value       = module.compute.alb_dns_name
}
