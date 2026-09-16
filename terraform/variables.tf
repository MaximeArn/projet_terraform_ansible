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
variable "availability_zones" {
  description = "Availability zones to spread the subnets across."
  type        = list(string)
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}
variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets. One per availability zone."
  type        = list(string)
}
variable "app_subnet_cidrs" {
  description = "CIDR blocks for the application private subnets. One per availability zone."
  type        = list(string)
}
variable "data_subnet_cidrs" {
  description = "CIDR blocks for the data private subnets. One per availability zone."
  type        = list(string)
}