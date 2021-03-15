variable "AWS_ACCOUNT_ID" {
  type = string
}

variable "AWS_DEFAULT_REGION" {
  default = "us-east-1"
  type    = string
}

variable "instant_name" {
  default = "express_api"
  type    = string
}

## Our image name built by cicd
variable "image_name" {
  default = "bitnami/express"
  type    = string
}

provider "aws" {
  region = var.AWS_DEFAULT_REGION
}

## TODO: Fix container definition, use a template or better a docker-stack.yml
## https://github.com/rearc/terraform-aws-ecs-task/blob/857d3f8cc36aa92d2b074626b3fc69d2f6b9de3e/main.tf#L11

module "ecs_task" {
  source         = "./infrastructure"
  aws_account_id = var.AWS_ACCOUNT_ID
  region         = var.AWS_DEFAULT_REGION
  name           = var.instant_name
  image          = var.image_name
}
