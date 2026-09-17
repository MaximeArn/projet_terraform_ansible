output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer — the application endpoint."
  value       = aws_lb.app.dns_name
}