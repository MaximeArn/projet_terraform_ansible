module "network" {
  source = "./modules/network"

  environment = var.environment
  aws_region  = var.aws_region
}