region               = "eu-central-1"
availability_zones   = ["eu-central-1a", "eu-central-1b"]
environment          = "dev"
name_prefix          = "librechatapp"
project              = "librechat-project"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

eks_instance_types      = ["t3.medium"]
node_group_desired_size = 1
node_group_max_size     = 2
node_group_min_size     = 1