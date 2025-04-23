variable "project" {
  type        = string
  description = "Project name"
}

locals {
  common_tags = {
    Project     = var.project
    ManagedBy   = "terraform"
    Environment = "global"
  }
}

variable "ecr_repo_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "image_tag_mutability" {
  type        = string
  description = "Whether image tags can be overwritten"
}

variable "scan_on_push" {
  type        = bool
  description = "Scan images on push"
}

variable "lifecycle_retention" {
  type        = number
  description = "Number of images to retain"
}

variable "lifecycle_tag_prefix" {
  type        = string
  description = "Tag prefix for lifecycle policy"
}