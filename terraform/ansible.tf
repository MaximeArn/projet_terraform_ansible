data "aws_instances" "app" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [module.compute.autoscaling_group_name]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

resource "ansible_group" "app" {
  name = "app"

  variables = {
    database_endpoint = module.database.endpoint
    database_port     = module.database.port
    efs_dns_name      = module.storage.file_system_dns_name
  }
}

resource "ansible_host" "app" {
  for_each = toset(data.aws_instances.app.ids)

  name   = each.value
  groups = ["app"]

  variables = {
    ansible_host           = each.value
    ansible_connection     = "amazon.aws.aws_ssm"
    ansible_aws_ssm_region = var.aws_region
  }
}

