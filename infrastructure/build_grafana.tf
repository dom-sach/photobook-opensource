resource "null_resource" "build_grafana" {
  provisioner "local-exec" {
    command = "build-grafana.bat"

    environment = {
      AWS_REGION = var.aws_region
      ECR_URL    = aws_ecr_repository.grafana.repository_url
    }
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    local_file.grafana_datasource,
    aws_ecr_repository.grafana
  ]
}
