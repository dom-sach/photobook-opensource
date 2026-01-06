resource "aws_ecs_task_definition" "backend" {
  family                   = "guestbook-backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  execution_role_arn = var.lab_role_arn
  task_role_arn      = var.lab_role_arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:postgresql://${aws_instance.db.private_ip}:5432/${var.db_name}"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = var.db_user
        },

        # === MinIO / S3 ===
        {
          name  = "S3_ENDPOINT"
          value = "http://${aws_lb.guestbook_alb.dns_name}/minio"
        },
        {
          name  = "S3_ACCESS_KEY"
          value = "minioadmin"
        },
        {
          name  = "S3_SECRET_KEY"
          value = "minioadmin"
        },
        {
          name  = "S3_BUCKET"
          value = "media"
        },

        {name= "dummy", value="hello"},

        # Dla Keycloaka EC2
        {
          name  = "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI"
          value = "http://${aws_lb.guestbook_alb.dns_name}/realms/guestbook"
        },
        {
          name  = "OIDC_ISSUER_URI"
          value = "http://${aws_lb.guestbook_alb.dns_name}/realms/guestbook"
        },
      ]

      secrets = [
        {
          name      = "SPRING_DATASOURCE_PASSWORD"
          valueFrom = aws_ssm_parameter.db_password.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "backend"
        }
      }
    }
  ])
}

# ECS Service (backend)
resource "aws_ecs_service" "backend" {
  name            = "guestbook-backend"
  cluster = aws_ecs_cluster.guestbook.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1

  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8080
  }

  depends_on = [
    aws_lb_listener_rule.api_backend
  ]
}
