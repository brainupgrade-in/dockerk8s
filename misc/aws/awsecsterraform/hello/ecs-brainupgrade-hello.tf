terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
}

resource "aws_default_vpc" "brainupgrade-hello" {
  provider = aws.ap-southeast-1

  tags = {
    env = "dev"
  }
}

resource "aws_default_subnet" "brainupgrade-hello" {
  provider          = aws.ap-southeast-1
  availability_zone = "ap-southeast-1a"

  tags = {
    env = "dev"
  }
}

resource "aws_default_subnet" "brainupgrade-hello-1" {
  provider          = aws.ap-southeast-1
  availability_zone = "ap-southeast-1b"


  tags = {
    env = "dev"
  }
}

resource "aws_security_group" "brainupgrade-hello" {
  provider = aws.ap-southeast-1

  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_default_vpc.brainupgrade-hello.id

  ingress {
    description = "Allow HTTP for all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "brainupgrade-hello" {
  provider = aws.ap-southeast-1

  name               = "brainupgrade-hello-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.brainupgrade-hello.id]
  subnets            = [aws_default_subnet.brainupgrade-hello.id, aws_default_subnet.brainupgrade-hello-1.id]
  tags = {
    env = "dev"
  }
}


resource "aws_lb_target_group" "brainupgrade-hello" {
  provider = aws.ap-southeast-1

  name        = "tf-brainupgrade-hello-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.brainupgrade-hello.id
}

resource "aws_lb_listener" "brainupgrade-hello" {
  provider = aws.ap-southeast-1

  load_balancer_arn = aws_lb.brainupgrade-hello.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.brainupgrade-hello.arn
  }
}


resource "aws_ecs_cluster" "brainupgrade-hello" {
  provider = aws.ap-southeast-1
  name     = "brainupgrade-hello-api-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "brainupgrade-hello" {
  provider = aws.ap-southeast-1

  cluster_name = aws_ecs_cluster.brainupgrade-hello.name

  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_task_definition" "brainupgrade-hello" {
  provider = aws.ap-southeast-1

  family                   = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([
    {
      name      = "brainupgrade-hello-api"
      image     = "brainupgrade/hello"
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "brainupgrade-hello" {
  provider = aws.ap-southeast-1

  name            = "brainupgrade-hello"
  cluster         = aws_ecs_cluster.brainupgrade-hello.id
  task_definition = aws_ecs_task_definition.brainupgrade-hello.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_default_subnet.brainupgrade-hello.id, aws_default_subnet.brainupgrade-hello-1.id]
    security_groups  = [aws_security_group.brainupgrade-hello.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.brainupgrade-hello.arn
    container_name   = "brainupgrade-hello-api"
    container_port   = 8080
  }

  tags = {
    env = "dev"
  }
}