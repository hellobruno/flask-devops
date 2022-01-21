# variables.tf

variable "aws_region" {
  description = "Value of London Region"
  type        = string
  default     = "eu-west-2"
}

variable "cluster_name" {
  type        = string
  description = "Name of AWS ECS cluster"
  default     = "flask-devops"
}