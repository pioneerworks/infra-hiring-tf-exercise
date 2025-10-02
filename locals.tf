locals {
  cluster_name         = "tf-takehome"
  aws_region           = "us-east-1"
  vpc_id               = "vpc-12345678"
  public_subnet_ids    = ["subnet-12345678", "subnet-87654321"]
  private_subnet_ids   = ["subnet-12345678", "subnet-87654321"]
  api_image            = "public.ecr.aws/docker/library/nginx:latest"
  admin_image          = "public.ecr.aws/docker/library/httpd:latest"
  api_container_port   = 8080
  admin_container_port = 8081
  instance_type        = "t3.small"
  desired_capacity     = 2
  min_size             = 2
  max_size             = 4
  ssh_key_name         = null
  db_username          = "appuser"
  db_password          = "changeme123!"
  db_name              = "appdb"
  db_instance_class    = "db.t4g.micro"


  userdata = <<-EOF
  #!/bin/bash
  set -eux
  cat > /etc/ecs/ecs.config <<EOC
  ECS_CLUSTER=${local.cluster_name}-cluster
  ECS_ENABLE_TASK_IAM_ROLE=true
  ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
  ECS_AWSVPC_BLOCK_IMDS=true
  EOC
EOF
}
