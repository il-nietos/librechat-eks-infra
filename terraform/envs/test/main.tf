terraform {
  backend "s3" {
    bucket         = "librechat-tf-state"
    key            = "test/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locking"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.9"
    }
  }
}

provider "aws" {
  region = var.region
}

# Simple SNS topic for testing the pipeline
resource "aws_sns_topic" "test_topic" {
  name = "librechat-pipeline-test-${var.environment}"
  tags = {
    Environment = var.environment
    Project     = var.project
    Name        = "${var.name_prefix}-test-topic"
  }
}