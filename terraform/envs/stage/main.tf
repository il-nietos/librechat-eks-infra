terraform {
  backend "s3" {
    bucket         = "librechat-tf-state"
    key            = "stage/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locking"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.9"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_eks_cluster_auth" "current" {
  name = module.eks.eks_cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name, "--region", var.region]

  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name, "--region", var.region]
    }
  }
}

# VPC Module
module "vpc" {
  source               = "../../modules/vpc"
  eks_cluster_name     = local.cluster_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  environment          = var.environment
  project              = var.project
  name_prefix          = var.name_prefix
  tags                 = local.common_tags
}

# EKS Cluster Module
module "eks" {
  source                  = "../../modules/eks"
  eks_cluster_name        = local.cluster_name
  region                  = var.region
  eks_instance_types      = var.eks_instance_types
  node_group_desired_size = var.node_group_desired_size
  node_group_min_size     = var.node_group_min_size
  node_group_max_size     = var.node_group_max_size
  vpc_id                  = module.vpc.vpc_id
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_subnet_ids      = module.vpc.private_subnet_ids
  environment             = var.environment
  project                 = var.project
  name_prefix             = var.name_prefix
  tags                    = local.common_tags
}

module "aws_lb_controller" {
  source                      = "../../modules/aws-lb-controller"
  eks_cluster_name            = local.cluster_name
  region                      = var.region
  vpc_id                      = module.vpc.vpc_id
  oidc_provider_arn           = module.eks.oidc_provider_arn
  oidc_provider_url           = module.eks.oidc_provider_url
  controller_version          = "1.6.1"
  controller_image_repository = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
  environment                 = var.environment
  project                     = var.project
  name_prefix                 = var.name_prefix
  tags                        = local.common_tags
}
