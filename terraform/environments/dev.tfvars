# this file is used to store infrastructure variables and NEVER secrets 

environment = "dev"
aws_region  = "eu-west-3"

availability_zones = ["eu-west-3a", "eu-west-3b"]

vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
app_subnet_cidrs     = ["10.0.11.0/24", "10.0.12.0/24"]
data_subnet_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"]
