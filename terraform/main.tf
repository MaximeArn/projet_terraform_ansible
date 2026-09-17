module "network" {
  source = "./modules/network"

  environment        = var.environment
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  app_port      = var.app_port
  database_port = var.database_port
}

module "compute" {
  source = "./modules/compute"

  environment      = var.environment
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  cpu_target_value = var.cpu_target_value
  app_port         = var.app_port

  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_subnet_ids     = module.network.private_subnet_ids
  alb_security_group_id  = module.network.alb_security_group_id
  app_security_group_id  = module.network.app_security_group_id
}
