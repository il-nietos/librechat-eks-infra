locals {
  name = "${var.name_prefix}-${var.environment}"
}

# Create IAM policy based on json file for aws lb controller
resource "aws_iam_policy" "aws_lb_controller" {
  name        = "${local.name}--AWSLoadBalancerControllerPolicy"
  description = "Policy for AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/aws-load-balancer-controller-iam-policy.json")
}

# Define the IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "lb_controller_role" {
  name = "${local.name}-lb-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
  tags = merge(
    var.tags,
    {
      Name = "${local.name}-aws-lb-controller-role"
    }
  )

}

# Define the Kubernetes ServiceAccount
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.lb_controller_role.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

# Define IAM-role pocicy attachment
resource "aws_iam_role_policy_attachment" "lb_controller_attach" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller.arn
}

# Install AWS Load Balancer Controller via Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.1"
  namespace  = "kube-system"
  timeout    = 600
  wait       = true
  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
  set {
    name  = "region"
    value = var.region
  }
  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.repository"
    value = var.controller_image_repository
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller_role.arn
  }

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller,
    aws_iam_role.lb_controller_role,
    aws_iam_role_policy_attachment.lb_controller_attach
  ]
}
