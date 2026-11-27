variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-2"
}

variable "owner" {
  description = "Owner tag applied to every resource."
  type        = string
  default     = "platform-team"
}

variable "environment" {
  description = "Environment tag applied to every resource."
  type        = string
  default     = "demo"
}

variable "cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
  default     = "runbook-demo"
}

variable "log_retention_in_days" {
  description = "Retention for the ECS cluster CloudWatch log group (at least 365)."
  type        = number
  default     = 365
}
