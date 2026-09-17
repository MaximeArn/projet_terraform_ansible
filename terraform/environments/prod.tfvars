# this file is used to store infrastructure variables and NEVER secrets
environment = "prod"
aws_region  = "eu-west-3"

availability_zones = ["eu-west-3a", "eu-west-3b"]

vpc_cidr = "10.0.0.0/16"

instance_type    = "t3.small"
min_size         = 2
max_size         = 4
desired_capacity = 2
