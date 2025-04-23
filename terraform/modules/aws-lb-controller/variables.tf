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

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "vpc if"
  type        = string
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL"
  type        = string
}

variable "controller_version" {
  description = "Controller version"
  type        = string
}

variable "controller_image_repository" {
  description = "Controller image repository"
  type        = string
}