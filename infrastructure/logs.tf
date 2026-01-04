resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/guestbook-backend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/guestbook-frontend"
  retention_in_days = 7
}
