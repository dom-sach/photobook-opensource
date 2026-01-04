resource "null_resource" "build_backend" {
  provisioner "local-exec" {
    command = "build-backend.bat"
    environment = {
      AWS_REGION = var.aws_region
      ECR_URL    = aws_ecr_repository.backend.repository_url
      VITE_BACKEND_URL          = "http://${aws_lb.guestbook_alb.dns_name}"
    }
  }
  triggers = { always_run = timestamp() }
}
