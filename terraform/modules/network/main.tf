resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "taylor-shift-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "taylor-shift-igw-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "taylor-shift-public-${var.availability_zones[count.index]}"
    Environment = var.environment
    Tier        = "public"
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 11)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "taylor-shift-private-${var.availability_zones[count.index]}"
    Environment = var.environment
    Tier        = "private"
  }
}

resource "aws_subnet" "database" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 21)
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "taylor-shift-database-${var.availability_zones[count.index]}"
    Environment = var.environment
    Tier        = "database"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "taylor-shift-public-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "taylor-shift-nat-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name        = "taylor-shift-nat-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = "taylor-shift-private-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "taylor-shift-database-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# Security groups 

resource "aws_security_group" "alb" {
  name        = "taylor-shift-alb-${var.environment}"
  description = "Security group for the ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "taylor-shift-alb-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = var.app_port
  to_port     = var.app_port
  ip_protocol = "tcp"
}
resource "aws_security_group" "app" {
  name        = "taylor-shift-app-${var.environment}"
  description = "Security group for the application instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "taylor-shift-app-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.alb.id

  from_port   = var.app_port
  to_port     = var.app_port
  ip_protocol = "tcp"
}

resource "aws_security_group" "database" {
  name        = "taylor-shift-database-${var.environment}"
  description = "Security group for the database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "taylor-shift-database-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "database_from_app" {
  security_group_id = aws_security_group.database.id

  referenced_security_group_id = aws_security_group.app.id

  from_port   = var.database_port
  to_port     = var.database_port
  ip_protocol = "tcp"
}

resource "aws_security_group" "efs" {
  name        = "taylor-shift-efs-${var.environment}"
  description = "Security group for the EFS mount targets"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "taylor-shift-efs-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs_from_app" {
  security_group_id = aws_security_group.efs.id

  referenced_security_group_id = aws_security_group.app.id

  from_port   = 2049
  to_port     = 2049
  ip_protocol = "tcp"
}
