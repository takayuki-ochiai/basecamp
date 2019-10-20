output "ecs_task_definition_role_arn" {
  value = module.ecs_task_definition_role.iam_role_arn
}

output "ecs_task_definition_role_name" {
  value = module.ecs_task_definition_role.iam_role_name
}

output "ec2_container_instance_role_arn" {
  value = module.ec2_container_instance_role.iam_role_arn
}

output "ec2_container_instance_role_name" {
  value = module.ec2_container_instance_role.iam_role_name
}
