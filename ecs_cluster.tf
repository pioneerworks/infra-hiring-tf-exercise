# Latest ECS-optimized AL2 AMI
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html

data "aws_ami" "ecs_al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Instance profile for ECS container instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.project_name}-ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_for_ec2" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.project_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# Security group for EC2 hosts

resource "aws_security_group" "ecs_hosts_sg" {
  name   = "${var.project_name}-ecs-hosts-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  userdata = <<-EOF
  #!/bin/bash
  set -eux
  cat > /etc/ecs/ecs.config <<EOC
  ECS_CLUSTER=${var.project_name}-cluster
  ECS_ENABLE_TASK_IAM_ROLE=true
  ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
  ECS_AWSVPC_BLOCK_IMDS=true
  EOC
EOF
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "${var.project_name}-ecs-lt-"
  image_id      = data.aws_ami.ecs_al2.id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
  vpc_security_group_ids = [aws_security_group.ecs_hosts_sg.id]

  user_data = base64encode(local.userdata)
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "${var.project_name}-ecs-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-host"
    propagate_at_launch = true
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"
}
