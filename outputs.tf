output "alb_dns_name" {
  value = aws_lb.external_alb.dns_name
}

output "api_url" {
  value = "http://${aws_lb.external_alb.dns_name}"
}

output "rds_endpoint" {
  value = aws_db_instance.pg.address
}
