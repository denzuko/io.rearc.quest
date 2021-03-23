provider "aws" {
  region = "us-east-1"
}

module "ecs_task" {
  source         = "../.."
  aws_account_id = "123456789012"
  region         = "us-east-1"
  name           = "express_api"
  image          = "bitnami/express"
}