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

module "ecs_task" {
  source          = "./infrastructure"
  aws_account_id  = var.AWS_ACCOUNT_ID
  region          = var.AWS_DEFAULT_REGION
  container_name  = var.instant_name
  container_image = var.image_name
}
