resource "aws_efs_file_system" "app" {
  creation_token = "taylor-shift-efs-${var.environment}"

  encrypted = true

  tags = {
    Name        = "taylor-shift-efs-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "app" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.app.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [var.efs_security_group_id]
}