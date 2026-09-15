variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging or prod."
  }
}