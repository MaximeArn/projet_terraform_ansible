variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets where EFS mount targets will be created."
  type        = list(string)
}

variable "efs_security_group_id" {
  description = "ID of the EFS security group."
  type        = string
}