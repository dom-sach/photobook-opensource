resource "aws_ecs_task_definition" "backend" {
  family                   = "guestbook-backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024

  execution_role_arn = var.lab_role_arn
  task_role_arn      = var.lab_role_arn

  container_definitions = jsonencode([
    # =========================
    # MINIO
    # =========================
    {
      name      = "minio"
      image     = "minio/minio:RELEASE.2024-10-13T13-34-11Z.fips"
      essential = true

      command = [
        "server",
        "/data",
        "--address", "0.0.0.0:9000",
        "--console-address", "0.0.0.0:9001"
      ]

      portMappings = [
        { containerPort = 9000, protocol = "tcp" },
        { containerPort = 9001, protocol = "tcp" }
      ]

      environment = [
        { name = "MINIO_ENDPOINT",    value = "http://localhost:9000" },
        { name = "MINIO_BUCKET",      value = var.minio_bucket },
        { name = "MEDIA_BUCKET", value = var.minio_bucket },
        { name = "MINIO_ACCESS_KEY",  value = var.minio_root_user },
        { name = "MINIO_SECRET_KEY",  value = var.minio_root_password },
        { name = "S3_ACCESS_KEY", value = var.minio_root_user },
        { name = "S3_SECRET_KEY", value = var.minio_root_password },
        { name = "MINIO_ROOT_USER",     value = var.minio_root_user },
        { name = "MINIO_ROOT_PASSWORD", value = var.minio_root_password },
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "minio"
        }
      }
    },

    # =========================
    # MINIO INIT (CREATE BUCKET)
    # =========================
    {
      name      = "minio-init"
      image     = "${aws_ecr_repository.minio.repository_url}:latest"
      essential = false

      dependsOn = [
        {
          containerName = "minio"
          condition     = "START"
        }
      ]

      environment = [
        { name = "MINIO_ENDPOINT",    value = "http://localhost:9000" },
        { name = "MINIO_BUCKET",      value = var.minio_bucket },
        { name = "MEDIA_BUCKET", value = var.minio_bucket },
        { name = "MINIO_ACCESS_KEY",  value = var.minio_root_user },
        { name = "MINIO_SECRET_KEY",  value = var.minio_root_password },
        { name = "S3_ACCESS_KEY", value = var.minio_root_user },
        { name = "S3_SECRET_KEY", value = var.minio_root_password },
        { name = "MINIO_ROOT_USER",     value = var.minio_root_user },
        { name = "MINIO_ROOT_PASSWORD", value = var.minio_root_password },
        {name="dummy", value = "minio"},
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "minio-init"
        }
      }
    },

    # =========================
    # BACKEND
    # =========================
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
        { name = "MINIO_ENDPOINT",    value = "http://localhost:9000" },
        { name = "MINIO_BUCKET",      value = var.minio_bucket },
        { name = "MEDIA_BUCKET", value = var.minio_bucket },
        { name = "MINIO_ACCESS_KEY",  value = var.minio_root_user },
        { name = "MINIO_SECRET_KEY",  value = var.minio_root_password },
        { name = "S3_ACCESS_KEY", value = var.minio_root_user },
        { name = "S3_SECRET_KEY", value = var.minio_root_password },
        { name = "MINIO_ROOT_USER",     value = var.minio_root_user },
        { name = "MINIO_ROOT_PASSWORD", value = var.minio_root_password },
        {name="dummy",  value = "http://localhost:8082" },

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
