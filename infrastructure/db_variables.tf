variable "db_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_name" {
  type    = string
  default = "guestbook"
}

variable "db_user" {
  type    = string
  default = "guestbook"
}

# variable "db_password" {
#   type        = string
#   description = "PostgreSQL password"
#   sensitive   = true
# }
