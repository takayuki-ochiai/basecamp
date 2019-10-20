output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "forward_to_ecs_arn" {
  value = aws_lb_target_group.forward_to_ecs.arn
}
