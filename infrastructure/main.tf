locals {
  image = var.image_tag == "latest" ? var.image : "${var.image}:${var.image_tag}"
  stack = var.stack != "" ? var.stack : var.environment
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${local.stack}_${var.name}"
  network_mode          = "awsvpc"
  task_role_arn         = var.task_role_arn
  execution_role_arn    = "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
  container_definitions = <<JSON
[{
    "cpu": 512,
    "essential": true,
    "memory": 1024,
    "memoryReservation": 512,
    "name": "${local.stack}_${var.name}",
    "image": local.image,
    "environment": concat([{ "PORT": var.container_port }], var.container_env),
    "portMappings": [{
	"containerPort": var.container_port
    }]
}]
JSON
}

resource "aws_ecs_service" "app_service" {
  count = length(var.private_subnets) == 0 ? 0 : 1

  name            = "${local.stack}_${var.name}"
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
    subnets = var.private_subnets
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
      container_name   = "${local.stack}_${var.name}"
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

  name               = "${local.stack}-${var.name}-scale-up"
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

  name               = "${local.stack}-${var.name}-scale-down"
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

  alarm_name          = "${local.stack}_${var.name}_autoscale_up"
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
  
  alarm_name          = "${local.stack}_${var.name}_autoscale_down"
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
