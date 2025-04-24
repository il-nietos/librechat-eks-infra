variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Environment name used for resource naming and tagging"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource naming"
}


variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "librechat-project"
    ManagedBy   = "terraform"
  }
}
