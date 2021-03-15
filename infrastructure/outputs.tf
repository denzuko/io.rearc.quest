output "listener_arn" {
  value = (length(var.public_subnets) == 0) ? "" : length(aws_lb_listener.alb_listener) == 0 ? "" : aws_lb_listener.alb_listener[0].arn
}

output "blue_target_group_arn" {
  value = (length(var.public_subnets) == 0) ? "" : length(aws_lb_target_group.alb_target_group_blue) == 0 ? "" : aws_lb_target_group.alb_target_group_blue[0].name
}

output "green_target_group_arn" {
  value = (length(var.public_subnets) == 0) ? "" : length(aws_lb_target_group.alb_target_group_green) == 0 ? "" : aws_lb_target_group.alb_target_group_green[0].name
}

output "app_sg_id" {
  value = (length(var.security_groups) == 0) ? length(var.private_subnets) == 0 ? "" : aws_security_group.app_sg[0].id : var.security_groups[0]
}

output "app_fqdn" {
  value = var.hosted_zone_id != "" ? aws_route53_record.www[0].fqdn : ""
}