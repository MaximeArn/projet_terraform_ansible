variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the application instances."
  type        = string
  default     = "t3.small"
}

variable "app_security_group_id" {
  description = "ID of the application security group"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets (from the network module)."
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of application instances."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of application instances."
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of application instances."
  type        = number
  default     = 2
}

variable "vpc_id" {
  description = "ID of the VPC (from the network module)."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets (from the network module)."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group (from the network module)."
  type        = string
}

variable "app_port" {
  description = "Port the application listens on."
  type        = number
}

variable "cpu_target_value" {
  description = "Target average CPU utilization (%) for the scaling policy."
  type        = number
  default     = 50
}
