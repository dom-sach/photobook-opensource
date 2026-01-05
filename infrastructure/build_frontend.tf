resource "null_resource" "build_frontend" {
  provisioner "local-exec" {
    command = "build-frontend.bat"

    environment = {
      AWS_REGION               = var.aws_region
      ECR_URL                  = aws_ecr_repository.frontend.repository_url
      VITE_BACKEND_URL        = "http://${aws_lb.guestbook_alb.dns_name}"
      VITE_FRONTEND_URL        = "http://${aws_lb.guestbook_alb.dns_name}"
      VITE_KEYCLOAK_URL = "http://${aws_lb.guestbook_alb.dns_name}"
      VITE_KEYCLOAK_REALM      = "guestbook"
      VITE_KEYCLOAK_CLIENT_ID = "guestbook-frontend"
    }
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    aws_lb.guestbook_alb,
    aws_ecr_repository.frontend,

  ]
}
