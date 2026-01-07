resource "null_resource" "build_minio_init_image" {
  provisioner "local-exec" {
    command = "build-minio.bat"
    environment = {
      AWS_REGION = var.aws_region
      ECR_URL    = aws_ecr_repository.minio.repository_url
    }
  }

  triggers = {
    always_run = timestamp()
  }
}
