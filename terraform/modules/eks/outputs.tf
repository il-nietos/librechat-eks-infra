output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the EKS OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.url
}

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.librechat-eks-cluster.name
}

output "cluster_endpoint" {
  description = "EKS Endpoint"
  value       = aws_eks_cluster.librechat-eks-cluster.endpoint
}

output "cluster_certificate_authority" {
  description = "EKS CA"
  value       = aws_eks_cluster.librechat-eks-cluster.certificate_authority[0].data
}

output "ebs_csi_driver" {
  value = aws_eks_addon.ebs_csi_driver
}

output "node_group_iam_role_arn" {
  value = aws_iam_role.node-group-role.arn
}