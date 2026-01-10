resource "null_resource" "build_prometheus" {
  provisioner "local-exec" {
    working_dir = path.module
    command     = "build-prometheus.bat"
    environment = {
      AWS_REGION = var.aws_region
      ECR_URL    = aws_ecr_repository.prometheus.repository_url
      ALB_DNS    = aws_lb.guestbook_alb.dns_name
    }
  }

  triggers = { always_run = timestamp() }

  depends_on = [aws_ecr_repository.prometheus]
}
