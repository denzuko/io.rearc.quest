variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "region" {
  type        = string
  description = "AWS Region, e.g. us-east-1"
  default     = null
}

variable "name" {
  type        = string
  description = "Name of the task to define for ECS"
  default     = null
}

variable "container_image" {
  type        = string
  description = "Name of image to run in ECS task"
  default     = null
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

variable "container_name" {
  type        = string
  description = "The name of the container. Allowed: /[\\w-]{1,255}/"
  default     = null
}

variable "container_essential" {
  default     = "true"
  type        = string
}

variable "container_reservation" {
  default     = "512"
  type        = string
}

variable "container_memory" {
  default     = "1024"
  type        = string
}

variable "container_cpu" {
  default     = "512"
  type        = string
}

variable "container_env" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "The Container related environment variables. This is a list of maps. map_environment overrides environment"
  default     = []
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

variable "entryPoint" {
  type        = list(string)
  description = "The entry point that is passed to the container"
  default     = null
}

variable "command" {
  type        = list(string)
  description = "The command that is passed to the container"
  default     = null
}

variable "working_directory" {
  type        = string
  description = "The working directory to run commands inside the container"
  default     = null
}

variable "extraHosts" {
  type = list(object({
    ipAddress = string
    hostname  = string
  }))
  description = "A list of hostnames and IP address mappings to append to the /etc/hosts file on the container. This is a list of maps"
  default     = null
}

