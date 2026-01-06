resource "aws_ecs_task_definition" "minio" {
  family                   = "guestbook-minio"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  execution_role_arn = var.lab_role_arn
  task_role_arn      = var.lab_role_arn


  container_definitions = jsonencode([
    {
      name  = "minio"
      image = "${aws_ecr_repository.minio.repository_url}:latest"

      portMappings = [
        { containerPort = 9000 },
        { containerPort = 9001 }
      ]

      environment = [
        { name = "MINIO_ROOT_USER", value = "minioadmin" },
        { name = "MINIO_ROOT_PASSWORD", value = "minioadmin" },
        { name = "MEDIA_BUCKET", value = "media" },
        { name = "S3_ACCESS_KEY", value = "minioadmin" },
        { name = "S3_SECRET_KEY", value = "minioadmin" },
        { name = "S3_BUCKET_NAME", value = "media" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "minio"
        }
      }

    }
  ])
}


resource "aws_ecs_service" "minio" {
  name            = "minio"
  cluster         = aws_ecs_cluster.guestbook.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.minio.arn
  desired_count   = 1

  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.minio.arn
    container_name   = "minio"
    container_port   = 9000
  }
}
