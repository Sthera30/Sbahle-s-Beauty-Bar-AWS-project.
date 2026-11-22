
# Here we are telling AWS to look up for the recommended AMI ID for creating our EC2 instance
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

# Here we are giving our EC2 instance permissions needed for our ECS Agent to communicate
# With ECS and Perform ECS related operations
# ECS Agent needs to:
# Register our EC2 instance with the cluster 
# Report available computing capacity
# Report whether tasks are running or stopped
# Communicate with the ECS Control Plane

resource "aws_iam_role" "ecs_instance" {
  name = "${var.project}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project}-ecs-instance-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.project}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name

  tags = {
    Name = "${var.project}-ecs-instance-profile"
  }
}

# Here we are creating our Security Group for our EC2 instance

resource "aws_security_group" "ecs_instance" {
  name        = "${var.project}-ecs-instance-sg"
  description = "Security group for ECS EC2 instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-ecs-instance-sg"
  }
}


# Here we are creating our Cluster

resource "aws_ecs_cluster" "this" {
  name = "${var.project}-cluster"

  tags = {
    Name = "${var.project}-cluster"
  }
}

# This launch template describes how we should create our EC2 instance

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project}-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  vpc_security_group_ids = [aws_security_group.ecs_instance.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${aws_ecs_cluster.this.name}" >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project}-ecs-instance"
    }
  }
}

# Here we are creating the Auto Scaling Group

resource "aws_autoscaling_group" "ecs" {
  name             = "${var.project}-ecs-asg"
  min_size         = 0
  max_size         = 1
  desired_capacity = 1

  vpc_zone_identifier = var.private_subnet_ids # when the ASG launches our EC2 istance, it should put it in the private subnet

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  protect_from_scale_in = false

  tag {
    key                 = "Name"
    value               = "${var.project}-ecs-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}

# Here we are creating a capacity provider

resource "aws_ecs_capacity_provider" "this" {
  name = "${var.project}-capacity-provider"


  # We are connecting the Capacity Provider to our ASG
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "DISABLED"
    managed_draining               = "DISABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100 # Tells the capacity provider to aim to use all the available computing capacity
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }
}

# Here we are connecting our cluster to the capacity provider

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [
    aws_ecs_capacity_provider.this.name
  ]
    default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
    base              = 1
  }
}
