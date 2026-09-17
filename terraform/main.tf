module "network" {
  source = "./modules/network"

  environment        = var.environment
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  app_port      = var.app_port
  database_port = var.database_port
}