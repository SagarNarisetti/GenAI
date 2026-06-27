# modules/eks

# Cluster Basic Information
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your EKS Kubernetes API"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.version
}

# Cluster Configuration
output "eks_cluster_platform_version" {
  description = "Platform version of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.platform_version
}

output "cluster_identity" {
  description = "OIDC identity provider information"
  value       = aws_eks_cluster.eks_cluster.identity
}

output "eks_cluster_certificate_authority" {
  description = "Base64 encoded certificate authority data"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  sensitive   = true
}

# Node Group Information
output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.eks_node_group.id
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.eks_node_group.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.eks_node_group.status
}

output "node_group_resources" {
  description = "Resources associated with the EKS node group"
  value       = aws_eks_node_group.eks_node_group.resources
}

# Security Group
output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster_sg.id
}

# OIDC Provider
output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC Provider"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


# Kubeconfig
output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.eks_cluster.name} --region ${data.aws_region.current.name}"
}

# Data sources
data "aws_region" "current" {}


# Comprehensive cluster summary
output "eks_cluster_summary" {
  description = "Complete EKS cluster configuration summary"
  value = {
    cluster_name              = aws_eks_cluster.eks_cluster.name
    cluster_arn               = aws_eks_cluster.eks_cluster.arn
    cluster_endpoint          = aws_eks_cluster.eks_cluster.endpoint
    cluster_version           = aws_eks_cluster.eks_cluster.version
    node_group_id             = aws_eks_node_group.eks_node_group.id
    node_group_status         = aws_eks_node_group.eks_node_group.status
    security_group_id         = aws_security_group.eks_cluster_sg.id
    oidc_provider_arn         = aws_iam_openid_connect_provider.eks.arn
    certificate_authority    = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  }
  sensitive = true
}

