variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for subnets"
}

variable "environment" {
  type        = string
  description = "Environment name"
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
  type        = map(string)
  description = "Common tags to apply to all resources"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  # default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  # default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  #default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}