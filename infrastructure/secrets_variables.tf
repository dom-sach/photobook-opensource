variable "db_password" {
  type        = string
  description = "PostgreSQL password (will be stored in SSM as SecureString)"
  sensitive   = true
}
