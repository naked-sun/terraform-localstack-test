# Certificate for SSL LB
# Create local self signed cert and import into ACM
resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "this" {
  private_key_pem       = tls_private_key.this.private_key_pem
  validity_period_hours = 24

  subject {
    common_name  = "testapp.com"
    organization = "Test APP"
  }

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "this" {
  private_key      = tls_private_key.this.private_key_pem
  certificate_body = tls_self_signed_cert.this.cert_pem
}

# Load Balancer
resource "aws_alb_target_group" "this" {
  name     = var.name
  port     = var.backend_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = var.name
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = var.backend_port
  }
}

resource "aws_alb_target_group_attachment" "this" {
  count = length(var.instance_id_list)

  target_group_arn = aws_alb_target_group.this.arn
  target_id        = element(var.instance_id_list, count.index)
  port             = var.backend_port
}

resource "aws_alb" "this" {
  name            = var.name
  subnets         = var.public_subnet_ids
  security_groups = [var.alb_sg_id]
  internal        = false
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.this.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.this.arn
  }
}