variable "region" {
  type        = string
  description = "AWS region"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for subnets"
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

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}

locals {
  cluster_name = "${var.name_prefix}-${var.environment}-cluster"
}

# locals {
#   name = "${var.name_prefix}-${var.environment}"
# }

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "eks_instance_types" {
  type        = list(string)
  description = "Instance types for node group instances"
}

variable "node_group_desired_size" {
  type        = number
  description = "EKS node group desired size (preferred number of instances)"
}

variable "node_group_max_size" {
  type        = number
  description = "EKS node group max size"
}

variable "node_group_min_size" {
  type        = number
  description = "EKS node group min size"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Environment = "stage"
    Project     = "librechat-project"
    ManagedBy   = "terraform"
  }
}
