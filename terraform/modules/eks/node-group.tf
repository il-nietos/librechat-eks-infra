# 1.i IAM for node group
resource "aws_iam_role" "node-group-role" {
  name = "${local.name}-eks-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-node-group-role"
    }
  )
}

# 1.ii Attach policies
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-group-role.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-group-role.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-group-role.name
}

# 2. EKS Node group
resource "aws_eks_node_group" "node_group" {
  cluster_name   = var.eks_cluster_name
  node_role_arn  = aws_iam_role.node-group-role.arn
  subnet_ids     = var.private_subnet_ids
  capacity_type  = "ON_DEMAND"
  instance_types = var.eks_instance_types

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "node_group"
  }
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-node-group"
    }
  )
  depends_on = [
    aws_eks_cluster.librechat-eks-cluster,
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}