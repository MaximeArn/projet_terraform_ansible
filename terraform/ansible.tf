data "aws_caller_identity" "current" {}

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
    database_endpoint      = module.database.endpoint
    database_port          = module.database.port
    efs_dns_name            = module.storage.file_system_dns_name
    ansible_aws_ssm_region  = var.aws_region
    ansible_aws_ssm_bucket_name = aws_s3_bucket.ssm.id
  }
}

resource "ansible_host" "app" {
  for_each = toset(data.aws_instances.app.ids)

  name   = each.value
  groups = ["app"]

  variables = {
    ansible_host       = each.value
    ansible_connection = "amazon.aws.aws_ssm"
  }
}


# Bucket used for the SSM connexion 

resource "aws_s3_bucket" "ssm" {
  bucket = "taylor-shift-ssm-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "taylor-shift-ssm-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "ssm" {
  bucket = aws_s3_bucket.ssm.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "ssm" {
  bucket = aws_s3_bucket.ssm.id

  rule {
    id     = "expire-transfer-files"
    status = "Enabled"

    expiration {
      days = 1
    }
  }
}

resource "aws_iam_role_policy" "ssm_transfer" {
  name = "taylor-shift-ssm-transfer-${var.environment}"
  role = module.compute.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.ssm.arn,
          "${aws_s3_bucket.ssm.arn}/*"
        ]
      }
    ]
  })
}

