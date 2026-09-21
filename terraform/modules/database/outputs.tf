output "endpoint" {
  description = "DNS endpoint of the RDS MySQL instance."
  value       = aws_db_instance.database.address
}

output "port" {
  description = "Port used by the RDS MySQL instance."
  value       = aws_db_instance.database.port
}

output "database_name" {
  description = "Name of the PrestaShop database."
  value       = aws_db_instance.database.db_name
}

output "username" {
  description = "Database username."
  value       = aws_db_instance.database.username
  sensitive   = true
}