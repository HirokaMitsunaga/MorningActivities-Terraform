
provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
  version = ">= 2.0"  
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 最小のCPUユニット
  memory                   = "512"  # 最小のメモリユニット
  execution_role_arn       = aws_iam_role.example.arn

  container_definitions = jsonencode([
    {
      name  = "example-container",
      image = "950365196319.dkr.ecr.ap-northeast-1.amazonaws.com/react-hello-world:latest",
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_iam_role" "example" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets =  data.aws_subnets.default.ids
    security_groups = [aws_security_group.example.id]
    assign_public_ip = true  # パブリックIPを割り当てる
  }

  desired_count = 1
}

resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
