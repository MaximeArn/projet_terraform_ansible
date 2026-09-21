output "file_system_id" {
  description = "ID of the EFS file system."
  value       = aws_efs_file_system.app.id
}

output "file_system_dns_name" {
  description = "DNS name of the EFS file system."
  value       = aws_efs_file_system.app.dns_name
}