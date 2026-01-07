# variable "aws_region" {
#   type        = string
#   description = "AWS region"
#   default     = "us-east-1"
# }
#
# variable "lab_role_arn" {
#   type        = string
#   description = "IAM role ARN provided by AWS Learner Lab (LabRole)"
# }
#
#
# # == Keycloak ==
# variable "keycloak_admin_user" {
#   type        = string
#   description = "Keycloak admin username"
#   default     = "admin"
# }
#
# variable "keycloak_admin_password" {
#   type        = string
#   description = "Keycloak admin password"
#   sensitive   = true
# }

variable "aws_region" {
  default = "us-east-1"
}

variable "lab_role_arn" {
  default = "arn:aws:iam::381587967119:role/LabRole"
}

variable "keycloak_admin_user" {
  default = "admin"
}

variable "smtp_user" {
  default = "keycloak"
  type = string
  description = "SMTP user for Keycloak emails"
}

variable "keycloak_admin_password" {
  default = "admin12345!"
}

# === MinIO
variable "minio_access_key" {
  type    = string
  default = "minioadmin"
}

variable "minio_secret_key" {
  type    = string
  default = "minioadmin"
}

variable "minio_bucket" {
  type    = string
  default = "media"
}

variable "minio_root_user" {
  type    = string
  default = "minioadmin"
}

variable "minio_root_password" {
  type      = string
  sensitive = true
  default   = "minioadmin"
}