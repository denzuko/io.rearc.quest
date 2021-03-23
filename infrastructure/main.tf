locals {
  image = var.image_tag == "latest" ? var.image : "${var.image}:${var.image_tag}"
  stack = var.stack != "" ? var.stack : var.environment

  env = jsonencode([{
    "name"  = "PORT",
    "value" = var.container_port,
    "name"  = "SECRET_WORD",
    "value" = "{flag:QmVoaW5kIGV2ZXJ5IHN1Y2Nlc3NmdWwgQ29kZXIgdGhlcmUgYW4gZXZlbiBtb3JlIHN1Y2Nlc3NmdWwgRGUtY29kZXIgdG8gdW5kZXJzdGFuZCB0aGF0IGNvZGUu}"
  }])

  command               = jsonencode(var.command)
  dnsSearchDomains      = jsonencode(var.dnsSearchDomains)
  dnsServers            = jsonencode(var.dnsServers)
  dockerLabels          = jsonencode(var.dockerLabels)
  dockerSecurityOptions = jsonencode(var.dockerSecurityOptions)
  entryPoint            = jsonencode(var.entryPoint)
  environment           = jsonencode(var.environment)
  extraHosts            = jsonencode(var.extraHosts)
  ulimits               = replace(jsonencode(var.ulimits), local.classes["digit"], "$1")
  volumesFrom = replace(
    replace(jsonencode(var.volumesFrom), "/\"1\"/", "true"),
    "/\"0\"/",
    "false",
  )

  # re2 ASCII character classes
  # https://github.com/google/re2/wiki/Syntax
  classes = {
    digit = "/\"(-[[:digit:]]|[[:digit:]]+)\"/"
  }

  links = jsonencode(var.links)
  healthCheck = replace(jsonencode(var.healthCheck), local.classes["digit"],
  "$1")

  linuxParameters = replace(
    replace(
      replace(jsonencode(var.linuxParameters), "/\"1\"/", "true"),
      "/\"0\"/",
      "false",
    ),
    local.classes["digit"],
    "$1",
  )

  logConfiguration_default = {
    logDriver = var.log_driver
    options = {
      awslogs-region : var.region,
      awslogs-group : aws_cloudwatch_log_group.rearc_quest.name
    }
  }

  logConfiguration = replace(
    replace(
      jsonencode(local.logConfiguration_default),
      "/\"1\"/",
      "true",
    ),
    "/\"0\"/",
    "false",
  )

  mountPoints = replace(
    replace(jsonencode(var.mountPoints), "/\"1\"/", "true"),
    "/\"0\"/",
    "false",
  )

  portMappings = replace(jsonencode(var.portMappings), "/\"([0-9]+\\.?[0-9]*)\"/", "$1")

  repositoryCredentials = jsonencode(var.repositoryCredentials)
  resourceRequirements  = jsonencode(var.resourceRequirements)
  systemControls        = jsonencode(var.systemControls)
  secrets               = jsonencode(var.secrets)

  container_definition  = format("[%s]", data.template_file.container_definition.rendered)
  container_definitions = replace(local.container_definition, "/\"(null)\"/", "$1")

}

data "template_file" "container_definition" {
  template = file("${path.module}/templates/container-definition.json.tpl")

  vars = {
    command                = local.command == "[]" ? "null" : local.command
    cpu                    = var.container_cpu == 0 ? "null" : var.container_cpu
    disableNetworking      = var.disableNetworking ? true : false
    dnsSearchDomains       = local.dnsSearchDomains == "[]" ? "null" : local.dnsSearchDomains
    dnsServers             = local.dnsServers == "[]" ? "null" : local.dnsServers
    dockerLabels           = local.dockerLabels == "{}" ? "null" : local.dockerLabels
    dockerSecurityOptions  = local.dockerSecurityOptions == "[]" ? "null" : local.dockerSecurityOptions
    entryPoint             = local.entryPoint == "[]" ? "null" : local.entryPoint
    environment            = local.env == "[]" ? "null" : local.env
    essential              = var.essential ? true : false
    extraHosts             = local.extraHosts == "[]" ? "null" : local.extraHosts
    healthCheck            = local.healthCheck == "{}" ? "null" : local.healthCheck
    image                  = var.image == "" ? "null" : var.image
    interactive            = var.interactive ? true : false
    links                  = local.links == "[]" ? "null" : local.links
    linuxParameters        = local.linuxParameters == "{}" ? "null" : local.linuxParameters
    portMappings           = local.portMappings == "[]" ? "null" : local.portMappings
    privileged             = var.privileged ? true : false
    pseudoTerminal         = var.pseudoTerminal ? true : false
    readonlyRootFilesystem = var.readonlyRootFilesystem ? true : false
    repositoryCredentials  = local.repositoryCredentials == "{}" ? "null" : local.repositoryCredentials
    resourceRequirements   = local.resourceRequirements == "[]" ? "null" : local.resourceRequirements
    secrets                = local.secrets == "[]" ? "null" : local.secrets
    systemControls         = local.systemControls == "[]" ? "null" : local.systemControls
    ulimits                = local.ulimits == "[]" ? "null" : local.ulimits
    user                   = var.user == "" ? "null" : var.user
    volumesFrom            = local.volumesFrom == "[]" ? "null" : local.volumesFrom
    workingDirectory       = var.workingDirectory == "" ? "null" : var.workingDirectory
    logConfiguration       = var.log_driver == "" ? "null" : local.logConfiguration
    memory                 = var.container_memory == 0 ? "null" : var.container_memory
    memoryReservation      = var.container_memoryReservation == 0 ? "null" : var.container_memoryReservation
    mountPoints            = local.mountPoints
    name                   = var.container_name == "" ? "null" : var.container_name

  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${local.stack}_${var.container_name}"
  network_mode          = "awsvpc"
  task_role_arn         = var.task_role_arn
  execution_role_arn    = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
  container_definitions = local.container_definition
}

resource "aws_ecs_service" "app_service" {
  count = length(var.private_subnets) == 0 ? 0 : 1

  name            = "${local.stack}_${var.container_name}"
  cluster         = var.ecs_cluster_name
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.minimum_capacity

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = length(var.security_groups) == 0 ? [aws_security_group.app_sg[0].id] : var.security_groups
  }

  dynamic "deployment_controller" {
    for_each = length(var.public_subnets) == 0 ? [] : [1]

    content {
      type = "CODE_DEPLOY"
    }
  }

  dynamic "load_balancer" {
    for_each = length(var.public_subnets) == 0 ? [] : [1]

    content {
      target_group_arn = aws_lb_target_group.alb_target_group_blue[0].arn
      container_name   = "${local.stack}_${var.container_name}"
      container_port   = var.container_port
    }
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  count = length(var.private_subnets) == 0 ? 0 : 1

  max_capacity       = var.maximum_capacity
  min_capacity       = var.minimum_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.app_service[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_scale_up" {
  count = length(var.private_subnets) == 0 ? 0 : 1

  name               = "${local.stack}-${var.container_name}-scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

}

resource "aws_appautoscaling_policy" "ecs_policy_scale_down" {
  count = length(var.private_subnets) == 0 ? 0 : 1

  name               = "${local.stack}-${var.container_name}-scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

}

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_autoscaling_up" {
  count = length(var.private_subnets) == 0 ? 0 : 1

  alarm_name          = "${local.stack}_${var.container_name}_autoscale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    ServiceName = aws_ecs_service.app_service[0].name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.ecs_policy_scale_up[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_cluster_autoscaling_down" {
  count = length(var.private_subnets) == 0 ? 0 : 1

  alarm_name          = "${local.stack}_${var.container_name}_autoscale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    ServiceName = aws_ecs_service.app_service[0].name
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions     = [aws_appautoscaling_policy.ecs_policy_scale_down[0].arn]
}

resource "aws_cloudwatch_log_group" "rearc_quest" {
  name = "rearc_quest_${local.stack}"
  tags = {
    environment = local.stack
    application = "rearc.io-quest"
    owner       = "dz-01"
  }

}
