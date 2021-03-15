<a href="https://www.rearc.io/data/">
    <img src="https://www.rearc.io/wp-content/uploads/2018/11/Logo.png" alt="Rearc Logo" title="Rearc Logo" height="52" />
</a>

# terraform-aws-ecs-task

Terraform module to provide an ECS task definition and optionally an ECS service and a load balancer to run a variety of workloads on ECS.

## Introduction

The module will create:

* ECS task definition
* ECS service (TBD)
* AutoScaling target, policies, and CloudWatch alarms (TBD)
* Required security groups (TBD)
* Application load balancer (TBD)
* Route53 A record (TBD)

## Usage

By default, this will create a task definition which can be run using the ECS [RunTask API](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_RunTask.html).
```hcl
module "ecs_task" {
  source                   = "git::https://github.com/rearc/terraform-aws-ecs-task.git"
  aws_account_id           = "123456789012"
  region                   = "us-east-1"
  name                     = "express_api"
  image                    = "bitnami/express"
}
```