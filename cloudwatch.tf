# CloudWatch Log Groups

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project_name}-api"
  retention_in_days = 7
}
resource "aws_cloudwatch_log_group" "admin" {
  name              = "/ecs/${var.project_name}-admin"
  retention_in_days = 7
}
