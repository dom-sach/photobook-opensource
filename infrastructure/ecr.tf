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
}

