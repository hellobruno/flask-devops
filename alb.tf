resource "aws_alb" "application_load_balancer" {
  name               = "flask-devops-lb-tf" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]
  ]
  # References the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

# Creates a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = data.aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.main.id # References the default VPC
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn # References our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # References our target group
  }
}