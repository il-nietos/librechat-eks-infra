resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.librechat-eks-cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.39.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-ebs-csi-driver"
    }
  )
}

# Required IAM role for the EBS CSI driver
resource "aws_iam_role" "ebs_csi_driver" {
  name = "${local.name}-ebs-csi-driver-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.librechat-eks-cluster.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.librechat-eks-cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-ebs-csi-driver-role"
    }
  )
}

# Attach required AWS managed policy
resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}


# Set up OIDC authentication
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.librechat-eks-cluster.identity[0].oidc[0].issuer
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-oidc-provider"
    }
  )
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.librechat-eks-cluster.identity[0].oidc[0].issuer
}