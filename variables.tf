variable "project_name" {
  type    = string
  default = "tf-takehome-ec2"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Existing networking (inputs)
variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

# Container images
variable "api_image" {
  type    = string
  default = "public.ecr.aws/docker/library/nginx:latest"
}

variable "admin_image" {
  type    = string
  default = "public.ecr.aws/docker/library/httpd:latest"
}

# App settings
variable "api_container_port" {
  type    = number
  default = 8080
}

variable "admin_container_port" {
  type    = number
  default = 8081
}

# EC2/ASG settings
variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "ssh_key_name" {
  type    = string
  default = null
}

# RDS settings
variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_password" {
  type      = string
  default   = "changeme123!"
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}
