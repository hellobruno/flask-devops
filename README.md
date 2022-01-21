# flask-devops – What is it?

Creation and deployment of a containerized Flask application using Terraform for a simple infrastructure that consists of:

- Virtual Private Cloud (VPC) with 3 public subnets in 3 AZs
- Elastic Container Service (ECS) with Fargate
- Application Load Balancer (ALB)

## Architecture 

![ECS-Arch](https://user-images.githubusercontent.com/96356161/150504361-e78652a8-84b4-49ca-b781-f7a2ef5c6b05.png)

## Before deploying

Edit `main.tf` file to customize backend preferences and change and create an s3 bucket to store tfstate.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "flask-devops-tfstate"
    key    = "state/terraform.tfstate"
    region = "eu-west-2"
  }
}
```

## How to deploy in and from your machine

* Clone the repo and initialize Terraform:

```bash
terraform init
```

* Plan a single modification on just a single resource, the Elastic Container Registry so we can work and build the docker image and then push it before applying all changes

```bash
terraform plan
```

* Plan modifications

```bash
terraform apply
```

* Retrieve an auth token and authenticate your Docker client to your registry. Don't forget to change ECR repository.

```
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 453194146499.dkr.ecr.eu-west-2.amazonaws.com
```

* Build docker image

```
docker build -t flask-devops .
```

* After build completes, tag image to push it

```
docker tag flask-devops:latest 453194146499.dkr.ecr.eu-west-2.amazonaws.com/flask-devops:latest
```

* Run this to push the image to your new AWS repository

```
docker push 453194146499.dkr.ecr.eu-west-2.amazonaws.com/flask-devops:latest
```

* Apply new changes, the output will be the Load Balancer's hostname.

```bash
terraform apply
```


## Description

Cluster created using container instances

The module `vpc` is imported from Terraform Registry.

In `ecs.tf` there are:
  - Container instances cluster
  - Task definition 
  - Web service
  - Security Group for the service
  - Roles associated

In `ecr.tf` there is:
  - Elastic Container Registry to store our docker image

In `alb.tf` there is:
  - Application Load Balancer w/ target and security groups and listener. 

In `alb.tf` there is:
  - The provisioning of a VPC with 3 public subnets. 

## Adaptable variables
  - Variables like name & region @ `variables.tf` 
  - `"cluster_name"`
  - `aws_region`

