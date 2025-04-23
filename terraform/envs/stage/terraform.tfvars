region               = "eu-central-1"
availability_zones   = ["eu-central-1a", "eu-central-1b"]
environment          = "stage"
name_prefix          = "librechatapp"
project              = "librechat-project"
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]

eks_instance_types      = ["t3.medium"]
node_group_desired_size = 1
node_group_max_size     = 2
node_group_min_size     = 1