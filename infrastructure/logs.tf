resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/guestbook-backend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/guestbook-frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "minio" {
  name              = "/ecs/minio"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana"
  retention_in_days = 7
}
