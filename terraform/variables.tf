variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block of the project VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the project."
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
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