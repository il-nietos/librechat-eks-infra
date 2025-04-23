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

variable "eks_cluster_version" {
  type        = string
  default     = "1.32"
  description = "Version of the EKS"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "vpc if"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
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

variable "region" {
  type        = string
  description = "AWS region"
}