output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer — the application endpoint."
  value       = aws_lb.app.dns_name
}

output "autoscaling_group_name" {
  description = "Name of the application Auto Scaling Group."
  value       = aws_autoscaling_group.app.name
}

output "iam_role_name" {
  description = "Name of the IAM role used by the application instances."
  value       = aws_iam_role.app.name
}
