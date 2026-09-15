resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "taylor-shift-${var.environment}"
    Environment = var.environment
  }
}