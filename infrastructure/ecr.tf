resource "aws_ecr_repository" "backend" {
  name = "guestbook-backend-oss"

  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

resource "aws_ecr_repository" "frontend" {
  name = "guestbook-frontend-oss"

  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

# MinIO
resource "aws_ecr_repository" "minio" {
  name = "guestbook-minio"
  force_delete = true
}

resource "aws_ecr_repository" "grafana" {
  name = "guestbook-grafana"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

resource "aws_ecr_repository" "prometheus" {
  name = "guestbook-prometheus"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }

}


