terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      owner       = var.owner
      environment = var.environment
      stack       = "runbook-demo"
      managed_by  = "apex"
    }
  }
}
