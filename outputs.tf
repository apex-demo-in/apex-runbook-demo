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

output "public_bucket_name" {
  description = "Name of the public download bucket."
  value       = module.public_downloads.s3_bucket_id
}

output "public_bucket_download_url" {
  description = "Base URL for downloading objects from the public bucket."
  value       = "https://${module.public_downloads.s3_bucket_bucket_regional_domain_name}/"
}
