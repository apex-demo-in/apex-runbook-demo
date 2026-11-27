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

output "vpc_id" {
  description = "ID of the stack VPC."
  value       = module.vpc.vpc_id
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance."
  value       = aws_instance.this.private_ip
}
