data "aws_subnet" "private_subnet" {
  count = length(var.private_subnets) == 0 ? 0 : 1

  id = var.private_subnets[0]
}

resource "aws_lb" "alb" {
  count = length(var.public_subnets) == 0 ? 0 : 1

  name               = replace("${local.stack}_${var.name}", "_", "")
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.alb_sg[0].id]
  internal           = false
  load_balancer_type = "application"
}

resource "aws_lb_target_group" "alb_target_group_blue" {
  count = length(var.public_subnets) == 0 ? 0 : 1

  name        = replace("${local.stack}_${var.name}_blue", "_", "")
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = length(var.public_subnets) == 0 ? "" : data.aws_subnet.private_subnet[0].vpc_id
  port        = var.container_port

  health_check {
    path = var.health_check_path
  }
}

resource "aws_lb_target_group" "alb_target_group_green" {
  count = length(var.public_subnets) == 0 ? 0 : 1

  name        = replace("${local.stack}_${var.name}_green", "_", "")
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = length(var.public_subnets) == 0 ? "" : data.aws_subnet.private_subnet[0].vpc_id
  port        = var.container_port

  health_check {
    path = var.health_check_path
  }

  depends_on = [aws_lb.alb]
}

data "aws_acm_certificate" "app_cert" {
  count = var.cert_domain != "" ? 1 : 0

  domain = var.cert_domain
}

resource "aws_lb_listener" "alb_listener" {
  count = length(var.public_subnets) == 0 ? 0 : 1

  load_balancer_arn = aws_lb.alb[0].arn
  port              = var.ingress_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group_blue[0].arn
    type             = "forward"
  }

  certificate_arn = data.aws_acm_certificate.app_cert[0].arn

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}

resource "aws_security_group" "alb_sg" {
  count = length(var.public_subnets) == 0 ? 0 : 1

  name        = "${local.stack}-${var.name}-alb-sg"
  description = "Allow HTTP from Anywhere into ALB"
  vpc_id      = length(var.public_subnets) == 0 ? "" : data.aws_subnet.private_subnet[0].vpc_id

  ingress {
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = length(var.security_groups) == 0 ? [aws_security_group.app_sg[0].id] : var.security_groups
  }

  tags = {
    Name = "${local.stack}-${var.name}-alb-sg"
  }
}

//allow inbound traffic only from load balancer
resource "aws_security_group" "app_sg" {
  count = length(var.security_groups) == 0 ? length(var.private_subnets) == 0 ? 0 : 1 : 0

  name        = "${local.stack}-${var.name}-app-sg"
  description = "Allow HTTP from from LB into instances"
  vpc_id      = length(var.public_subnets) == 0 ? "" : data.aws_subnet.private_subnet[0].vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.stack}-${var.name}-app-sg"
  }
}

resource "aws_security_group_rule" "alb_sg_rule" {
  count = length(var.security_groups) == 0 ? length(var.private_subnets) == 0 ? 0 : 1 : 0

  security_group_id        = aws_security_group.app_sg[0].id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = length(aws_security_group.alb_sg) > 0 ? aws_security_group.alb_sg[0].id : ""
  description              = "{local.stack}_{var.container_name}"
}

resource "aws_security_group_rule" "app_sg_rule" {
  count = length(var.security_groups) == 0 ? length(var.private_subnets) == 0 ? 0 : 1 : 0

  security_group_id        = aws_security_group.app_sg[0].id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.app_sg[0].id
  description              = "{local.stack}_{var.container_name}"

}
