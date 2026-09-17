# this file is used to store infrastructure variables and NEVER secrets 

environment = "dev"
aws_region  = "eu-west-3"

availability_zones = ["eu-west-3a", "eu-west-3b"]

vpc_cidr = "10.0.0.0/16"

instance_type    = "t3.micro"
min_size         = 1
max_size         = 2
desired_capacity = 1
