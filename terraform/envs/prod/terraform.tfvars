region               = "eu-central-1"
availability_zones   = ["eu-central-1a", "eu-central-1b"]
environment          = "prod"
name_prefix          = "librechatapp"
project              = "librechat-project"
vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.3.0/24", "10.2.4.0/24"]

eks_instance_types      = ["t3.medium"]
node_group_desired_size = 2
node_group_max_size     = 4
node_group_min_size     = 2