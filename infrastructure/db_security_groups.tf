# resource "aws_security_group" "db_sg" {
#   name   = "guestbook-db-sg"
#   vpc_id = aws_vpc.main.id
#
#   ingress {
#     description     = "Postgres from ECS"
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ecs_sg.id]
#   }
#
#   ingress {
#     description = "SSH from my IP (optional)"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # możesz potem zawęzić
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
