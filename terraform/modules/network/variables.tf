variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region used for the deployment."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones used by the network."
  type        = list(string)
}

variable "app_port" {
  description = "Port the application listens on."
  type        = number
  default     = 80
}

variable "database_port" {
  description = "Port the database listens on."
  type        = number
  default     = 3306
}
