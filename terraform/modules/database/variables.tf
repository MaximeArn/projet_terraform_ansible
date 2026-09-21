variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "database_subnet_ids" {
  description = "IDs of the database subnets created by the network module."
  type        = list(string)
}

variable "database_security_group_id" {
  description = "ID of the security group allowing application access to the database."
  type        = string
}

variable "database_name" {
  description = "Name of the PrestaShop database."
  type        = string
  default     = "prestashop"
}

variable "database_username" {
  description = "Master username for the database."
  type        = string
  default     = "prestashop"
}

variable "database_password" {
  description = "Master password for the database."
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "database_port" {
  description = "Port used by MySQL."
  type        = number
  default     = 3306
}