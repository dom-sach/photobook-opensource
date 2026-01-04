# vpc
# resource "aws_vpc" "keycloak" {
#   cidr_block           = "10.20.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true
# }

# subnet
# resource "aws_subnet" "keycloak_public" {
#   count                   = 2
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
#   map_public_ip_on_launch = true
# }

# target group
# resource "aws_lb_target_group" "keycloak" {
#   vpc_id     = aws_vpc.keycloak.id
#   port       = 8180
#   protocol   = "HTTP"
#   target_type = "instance"
# }


resource "aws_security_group" "keycloak" {
  name   = "keycloak-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 8180
    to_port         = 8180
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "keycloak" {
  name        = "keycloak-tg"
  port        = 8180
  protocol    = "HTTP"
  vpc_id     = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health/ready"
    protocol            = "HTTP"
    port                = "9000"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener_rule" "keycloak" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 5

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.keycloak.arn
  }

  condition {
    path_pattern {
      values = ["/.well-known/*", "/realms/*", "/resources/*", "/admin/*"]
    }
  }
}


# INSTANCJA EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "keycloak-ec2-profile"
  role = "LabRole"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "keycloak" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.keycloak.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile(
    "${path.module}/user_data/user-data-keycloak.sh.tpl",
    {
      alb_dns = aws_lb.guestbook_alb.dns_name,
      smtp_user = var.smtp_user,
      smtp_app_password = var.smtp_user
    }
  )
  user_data_replace_on_change = true

  tags = {
    Name = "keycloak-ec2"
  }
}

output "keycloak_base_url" {
  description = "Base URL of Keycloak (via ALB)"
  value       = "http://${aws_lb.guestbook_alb.dns_name}"
}

output "keycloak_admin_url" {
  description = "Keycloak admin console"
  value       = "http://${aws_lb.guestbook_alb.dns_name}/admin/"
}

output "keycloak_realm_url" {
  description = "Keycloak realm base URL"
  value       = "http://${aws_lb.guestbook_alb.dns_name}/realms/guestbook"
}

output "keycloak_account_console" {
  description = "Keycloak user account / login UI"
  value       = "http://${aws_lb.guestbook_alb.dns_name}/realms/guestbook/account"
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "guestbook-private-${count.index}"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "guestbook-private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private[0].id
  route_table_id = aws_route_table.private.id
}



variable "smtp_user" {
  type        = string
  description = "SMTP user for Keycloak emails"
}


resource "aws_lb_target_group_attachment" "keycloak" {
  target_group_arn = aws_lb_target_group.keycloak.arn
  target_id        = aws_instance.keycloak.id
  port             = 8180
}
