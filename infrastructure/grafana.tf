resource "aws_ecs_task_definition" "grafana" {
  family                   = "guestbook-grafana"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  execution_role_arn = var.lab_role_arn
  task_role_arn      = var.lab_role_arn

  volume {
    name = "grafana-provisioning"
  }

  container_definitions = jsonencode([
    {
      name  = "grafana"
      image = "${aws_ecr_repository.grafana.repository_url}:latest"

      portMappings = [
        { containerPort = 3000 }
      ]

      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = "admin" },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = "admin" },
        { name = "GF_SERVER_ROOT_URL", value = "%(protocol)s://%(domain)s/grafana/" },
        { name = "GF_SERVER_SERVE_FROM_SUB_PATH", value = "true" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.grafana.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "grafana"
        }
      }
    }
  ])

}

resource "aws_ecs_service" "grafana" {
  name            = "grafana"
  cluster         = aws_ecs_cluster.guestbook.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1

  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana_tg.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.http
  ]
}

# render pliku datasource.yml
data "template_file" "grafana_datasource" {
  template = file("${path.module}/grafana-datasource.yml.tpl")

  vars = {
    alb_dns = aws_lb.guestbook_alb.dns_name
  }
}

resource "local_file" "grafana_datasource" {
  content  = data.template_file.grafana_datasource.rendered
  filename = "${path.module}/grafana/provisioning/datasources/datasource.yml"
}
