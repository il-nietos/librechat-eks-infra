# 1.i. IAM for cluster / control plane
resource "aws_iam_role" "eks-cluster-role" {
  name = "${local.name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"

        }
      },
    ]
  })
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-cluster-role"
    }
  )
}

# 1.ii. Attach policy 
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

# 2. EKS control plane
resource "aws_eks_cluster" "librechat-eks-cluster" {
  name     = var.eks_cluster_name
  version  = var.eks_cluster_version
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks.id]
  }
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  upgrade_policy {
    support_type = "STANDARD"
  }
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-cluster"
    }
  )
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_security_group" "eks" {
  name        = "${local.name}-eks-security-group"
  description = "Allow traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Kubernetes API server"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-cluster",
      "kubernetes.io/cluster/${var.eks_cluster_name}" : "owned"
    }
  )
}

