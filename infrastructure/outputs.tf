output "alb_dns_name" {
  value = aws_lb.guestbook_alb.dns_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

# dla db
# output "db_private_ip" {
#   value = aws_instance.db.private_ip
# }
#
# output "db_public_ip" {
#   value = aws_instance.db.public_ip
# }

output "backend_url" {
  value = "http://${aws_lb.guestbook_alb.dns_name}/api"
}


output "frontend_url" {
  description = "Frontend URL"
  value       = "http://${aws_lb.guestbook_alb.dns_name}"
}

output "frontend_build_env" {
  value = {
    AWS_REGION              = var.aws_region
    ECR_URL                 = aws_ecr_repository.frontend.repository_url
    VITE_BACKEND_URL        = "http://${aws_lb.guestbook_alb.dns_name}"
  }
}
