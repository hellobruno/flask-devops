# ecf.tf

# Creates the cluster
resource "aws_ecs_cluster" "flask-devops-cluster" {
  name = var.cluster_name # Naming the cluster
}

# Creates the task

resource "aws_ecs_task_definition" "task-definition-test" {
  family                   = "web-family" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "task-definition-test",
      "image": "${aws_ecr_repository.flask-devops.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # States that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifies the memory our container requires
  cpu                      = 256         # Specifies the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "service" {
  name            = "task-definition-test"
  cluster         = aws_ecs_cluster.flask-devops-cluster.id
  task_definition = aws_ecs_task_definition.task-definition-test.arn
  launch_type     = "FARGATE"
  desired_count   = 3 # Sets the number of containers deployed to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # References our target group
    container_name   = "task-definition-test"
    container_port   = 5000 # Specifies the container port
  }

  network_configuration {
    subnets          = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
    assign_public_ip = true                                                # Provides our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group

  }
}

# Creates a Security Group for the ECS service
resource "aws_security_group" "service_security_group" {
  vpc_id = data.aws_vpc.main.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allows traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0             # Allows any incoming port
    to_port     = 0             # Allows any outgoing port
    protocol    = "-1"          # Allows any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allows traffic out to all IP addresses
  }
}