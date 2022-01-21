# ecr.tf

resource "aws_ecr_repository" "flask-devops" {
  name = "flask-devops" # Repository name
}