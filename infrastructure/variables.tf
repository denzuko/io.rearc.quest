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

variable "dnsSearchDomains" {
  default     = []
  description = "A list of DNS search domains that are presented to the container"
  type        = list(string)
}

variable "dnsServers" {
  default     = []
  description = "A list of DNS servers that are presented to the container"
  type        = list(string)
}

variable "dockerLabels" {
  default     = {}
  description = "A key/value map of labels to add to the container"
  type        = map(string)
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
  default = "true"
  type    = string
}

variable "container_memoryReservation" {
  default     = "512"
  type        = string
  description = "The soft limit (in MiB) of memory to reserve for the container"
}

variable "container_memory" {
  default     = "1024"
  type        = string
  description = "The hard limit (in MiB) of memory to present to the container"
}

variable "container_cpu" {
  default = "512"
  type    = string
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

variable "readonlyRootFilesystem" {
  default     = false
  description = "When this parameter is true, the container is given read-only access to its root file system"
}

variable "privileged" {
  default     = false
  description = "When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user)"
}

variable "pseudoTerminal" {
  default     = false
  description = "When this parameter is true, a TTY is allocated"
}

variable "user" {
  default     = ""
  description = "The user name to use inside the container"
}

variable "volumes" {
  default     = []
  description = "A list of volume definitions in JSON format that containers in your task may use"
  type        = list(string)
}

variable "volumesFrom" {
  default     = []
  description = "Data volumes to mount from another container"
  type        = list(string)
}

variable "workingDirectory" {
  default     = ""
  description = "The working directory in which to run commands inside the container"
}

variable "log_driver" {
  default     = "awslogs"
  description = "The log driver to use for the container. Fargate supported log drivers are awslogs and splunk."
}

variable "log_options" {
  default     = {}
  description = "Logging options for the log_driver"
  type        = map(string)
}

variable "image" {
  default     = ""
  description = "The image used to start a container"
}

variable "dockerSecurityOptions" {
  default     = []
  description = "A list of strings to provide custom labels for SELinux and AppArmor multi-level security systems"
  type        = list(string)
}

variable "disableNetworking" {
  default     = false
  description = "When this parameter is true, networking is disabled within the container"
}

variable "essential" {
  default     = true
  description = "If the essential parameter of a container is marked as true, and that container fails or stops for any reason, all other containers that are part of the task are stopped"
}

variable "healthCheck" {
  default     = {}
  description = "The health check command and associated configuration parameters for the container"
  type        = map(string)
}

variable "hostname" {
  default     = ""
  description = "The hostname to use for your container"
}


variable "interactive" {
  default     = false
  description = "When this parameter is true, this allows you to deploy containerized applications that require stdin or a tty to be allocated"
}

variable "links" {
  default     = []
  description = "The link parameter allows containers to communicate with each other without the need for port mappings"
  type        = list(string)
}

variable "linuxParameters" {
  default     = {}
  description = "Linux-specific modifications that are applied to the container, such as Linux KernelCapabilities"
  type        = map(string)
}

variable "logConfiguration" {
  default     = {}
  description = "The log configuration specification for the container"
  type        = map(string)
}

variable "mountPoints" {
  default     = []
  description = "The mount points for data volumes in your container"
  type        = list(string)
}

variable "portMappings" {
  default     = []
  description = "The list of port mappings for the container"
  type = list(object({
    containerPort = number
    protocol      = string
  }))
}

variable "repositoryCredentials" {
  default     = {}
  description = "The private repository authentication credentials to use"
  type        = map(string)
}

variable "resourceRequirements" {
  default     = []
  description = "The type and amount of a resource to assign to a container"
  type        = list(string)
}

variable "secrets" {
  default     = []
  description = "The secrets to pass to the container"
  type        = list(map(string))
}

variable "systemControls" {
  default     = []
  description = "A list of namespaced kernel parameters to set in the container"
  type        = list(string)
}

variable "ulimits" {
  default     = []
  description = "A list of ulimits to set in the container"
  type        = list(string)
}
