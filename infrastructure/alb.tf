# === Load Balancer ===
resource "aws_lb" "guestbook_alb" {
  name               = "guestbook-alb-oss"
  load_balancer_type = "application"
  internal           = false # jest publiczny

  # Internet --> ALB (80)
  # ALB --> ECS
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = aws_subnet.public[*].id
}

# Listener dla ALB - nasłuchiwanie na porcie 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.guestbook_alb.arn
  port              = 80
  protocol          = "HTTP"

  # jeśli nic nie dopasuje - wysyła na front
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}


# Target Group dla backendu
resource "aws_lb_target_group" "backend" {
  name        = "guestbook-backend-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip" # ALB wysyła requesty bezpośrednio do IP tasków
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }
}

# Target group dla frontu
resource "aws_lb_target_group" "frontend" {
  name        = "guestbook-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Target group dla Prometheus
resource "aws_lb_target_group" "prometheus_tg" {
  name        = "prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path = "/prometheus/-/healthy"
  }
}

# target group dla Grafana
resource "aws_lb_target_group" "grafana_tg" {
  name        = "grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path = "/api/health"
  }
}

# Target group dla minio
resource "aws_lb_target_group" "minio" {
  name        = "guestbook-minio"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/minio/health/ready"
    port                = "9000"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }
}


# === LISTENER RULES ===

# Listener /api/* --> backend
resource "aws_lb_listener_rule" "api_backend" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# Listener dla /media/* --> MinIO
resource "aws_lb_listener_rule" "media_minio" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.minio.arn
  }

  condition {
    path_pattern {
      values = ["/media/*"]
    }
  }
}

# Listener dla /prometheus/* --> prometheus
resource "aws_lb_listener_rule" "prometheus_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_tg.arn
  }

  condition {
    path_pattern {
      values = ["/prometheus/*"]
    }
  }
}

# Listener dla /grafana/* --> Grafana
resource "aws_lb_listener_rule" "grafana_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 120

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }

  condition {
    path_pattern {
      values = ["/grafana/*"]
    }
  }
}