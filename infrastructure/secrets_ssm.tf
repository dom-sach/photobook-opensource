resource "aws_ssm_parameter" "db_password" {
  name        = "/guestbook/db/password"
  description = "Guestbook DB password"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Name = "guestbook-db-password"
  }
}
