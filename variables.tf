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

variable "vpc_cidr" {
  description = "CIDR block for the stack VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "instance_name" {
  description = "Name of the EC2 instance."
  type        = string
  default     = "runbook-demo-ec2"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root volume size in GiB."
  type        = number
  default     = 8
}
