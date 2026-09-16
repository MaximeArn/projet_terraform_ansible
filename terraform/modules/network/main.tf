# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "taylor-shift-${var.environment}"
    Environment = var.environment
  }
}

# Subnets 

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "taylor-shift-${var.environment}-public-${count.index}"
    Environment = var.environment
    Tier        = "public"
  }
}

resource "aws_subnet" "app" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "taylor-shift-${var.environment}-app-${count.index}"
    Environment = var.environment
    Tier        = "app"
  }
}

resource "aws_subnet" "data" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.data_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "taylor-shift-${var.environment}-data-${count.index}"
    Environment = var.environment
    Tier        = "data"
  }
}


