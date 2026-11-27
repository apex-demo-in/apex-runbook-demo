output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = module.ecs.cluster_arn
}

output "kms_key_arn" {
  description = "ARN of the stack KMS key."
  value       = aws_kms_key.stack.arn
}
