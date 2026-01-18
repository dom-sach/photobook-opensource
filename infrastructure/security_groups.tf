# ALB
resource "aws_security_group" "alb_sg" {
  name   = "guestbook-alb-sg"
  vpc_id = aws_vpc.main.id

  # dostęp dla całego internetu na porcie http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # wyjście wszędzie i na wszystko
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECSy
# przypięte do backendu, frontu, keycloaka,
# grafany, prometheusa, minio
resource "aws_security_group" "ecs_sg" {
  name   = "guestbook-ecs-sg"
  vpc_id = aws_vpc.main.id

  # kontenery przyjmują ruch tylko z ALB, na dowolnym porcie
  # backend 8080, frontend 80, grafana 3000,
  # prometheus 9090, minio 9000
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  # kontenery wypuszczają ruch gdzie chcą
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Baza danych dla metadanych obrazkow
resource "aws_security_group" "db_sg" {
  name   = "guestbook-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





