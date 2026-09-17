data "aws_ami" "app" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "app" {
  name = "taylor-shift-app-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "taylor-shift-app-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "taylor-shift-app-${var.environment}"
  role = aws_iam_role.app.name
}

# C'est le modele d'une de nos instance ec2. Ca va etre utilisé par le ScalingGroup 
resource "aws_launch_template" "app" {
  name_prefix   = "taylor-shift-app-${var.environment}-"
  image_id      = data.aws_ami.app.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "taylor-shift-app-${var.environment}"
      Environment = var.environment
    }
  }

  tags = {
    Name        = "taylor-shift-app-lt-${var.environment}"
    Environment = var.environment
  }
}


resource "aws_autoscaling_group" "app" {
  name                = "taylor-shift-app-${var.environment}"
  vpc_zone_identifier = var.private_subnet_ids

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = "ELB"
  health_check_grace_period = 300

  target_group_arns = [aws_lb_target_group.app.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "taylor-shift-app-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}


resource "aws_lb" "app" {
  name               = "taylor-shift-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"

  subnets         = var.public_subnet_ids
  security_groups = [var.alb_security_group_id]

  tags = {
    Name        = "taylor-shift-alb-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "app" {
  name     = "taylor-shift-app-${var.environment}"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }

  tags = {
    Name        = "taylor-shift-app-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                    = "taylor-shift-app-cpu-${var.environment}"
  autoscaling_group_name  = aws_autoscaling_group.app.name
  policy_type             = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}
