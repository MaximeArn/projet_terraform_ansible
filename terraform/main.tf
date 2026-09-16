module "network" {
  source = "./modules/network"

  environment = var.environment
  aws_region  = var.aws_region
  availability_zones = var.availability_zones
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs = var.app_subnet_cidrs
  data_subnet_cidrs = var.data_subnet_cidrs
}