terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.9"
    }
  }

  backend "s3" {
    bucket         = "librechat-tf-state"
    key            = "global/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locking"
  }
}

provider "aws" {
  region = "eu-central-1"
}

# ECR Repository
resource "aws_ecr_repository" "librechat_ecr_repo" {
  name                 = var.ecr_repo_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-global-ecr"
    }
  )
}


resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository = aws_ecr_repository.librechat_ecr_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only ${var.lifecycle_retention} images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = [var.lifecycle_tag_prefix]
          countType     = "imageCountMoreThan"
          countNumber   = var.lifecycle_retention
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}