variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "region" {
  type        = string
  description = "AWS Region, e.g. us-east-1"
}

variable "name" {
  type        = string
  description = "Name of the task to define for ECS"
}

variable "image" {
  type        = string
  description = "Name of image to run in ECS task"
}

variable "environment" {
  type        = string
  description = "Infrastructure environment, e.g. staging or production"
  default     = "staging"
}

variable "stack" {
  type        = string
  description = "Name to differentiate applications deployed in the same infrastructure environment"
  default     = ""
}

variable "image_tag" {
  type        = string
  description = "Image tag to run in ECS task"
  default     = "latest"
}

variable "task_role_arn" {
  type        = string
  description = "IAM role to run ECS task with"
  default     = null
}

variable "ecs_cluster_name" {
  type        = string
  description = "Elastic Container Service cluster name to deploy services to"
  default     = ""
}

variable "public_subnets" {
  type        = list(string)
  description = "VPC subnets to run ALB in"
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "VPC subnets to run ECS task in"
  default     = []
}

variable "security_groups" {
  type        = list(string)
  description = "VPC security groups to run ECS task in"
  default     = []
}

variable "container_env" {
  type        = list(map(any))
  description = "Container related environment varables"
  default     = [{
	"SECRET_WORD": "{flag:QmVoaW5kIGV2ZXJ5IHN1Y2Nlc3NmdWwgQ29kZXIgdGhlcmUgYW4gZXZlbiBtb3JlIHN1Y2Nlc3NmdWwgRGUtY29kZXIgdG8gdW5kZXJzdGFuZCB0aGF0IGNvZGUu}"
  }]
}

variable "container_port" {
  type        = string
  description = "Port to expose in ECS task container"
  default     = "3000"
}

variable "hosted_zone_id" {
  type        = string
  description = "Zone to create Route53 record in"
  default     = ""
}

variable "app_domain" {
  type        = string
  description = "Name of A record to create in zone"
  default     = ""
}

variable "cert_domain" {
  type        = string
  description = "Certificate in ACM to use"
  default     = ""
}

variable "minimum_capacity" {
  type        = number
  description = "Minimum number of tasks in ECS service"
  default     = 0
}

variable "maximum_capacity" {
  type        = number
  description = "Maximum number of tasks in ECS service"
  default     = 0
}

variable "ingress_port" {
  type        = string
  description = "Port for ALB to listen on"
  default     = "443"
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks to allow into ALB"
  default     = ["0.0.0.0/0"]
}

variable "health_check_path" {
  type        = string
  description = "Path to check target for healthiness"
  default     = "/"
}
