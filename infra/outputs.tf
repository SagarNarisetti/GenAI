output "access_key_id" {
  description = "Access key ID for the IAM user"
  value       = module.iam.access_key_id
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret access key for the IAM user"
  value       = module.iam.secret_access_key
  sensitive   = true
}

output "mleng_user_arn" {
  description = "ARN of IAM user"
  value = module.iam.mleng_user_arn
}

output "mleng_user_name" {
  description = "Name of IAM user"
  value = module.iam.mleng_user_name
}

output "mleng_role_arn" {
  description = "ARN of IAM role"
  value = module.iam.mleng_role_arn
}

output "mleng_role_name" {
  description = "Name of IAM role"
  value = module.iam.mleng_role_name
}

output "mleng_policy_arn" {
  description = "ARN of IAM policy"
  value = module.iam.mleng_policy_arn
}

output "mleng_policy_name" {
  description = "Name of IAM policy"
  value = module.iam.mleng_policy_name
}

# EKS IAM Role Outputs

# Networking Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.networking.public_subnet_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = module.networking.nat_gateway_public_ip
}

# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = module.ecr.repository_arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_registry_id" {
  description = "Registry ID (AWS Account ID)"
  value       = module.ecr.repository_registry_id
}

output "ecr_docker_login_command" {
  description = "Docker login command for ECR"
  value       = module.ecr.docker_login_command
  sensitive   = true
}

output "ecr_docker_push_command" {
  description = "Template command to push images to ECR"
  value       = module.ecr.docker_push_command
}

output "ecr_summary" {
  description = "ECR repository configuration summary"
  value       = module.ecr.ecr_summary
}

# EKS Outputs
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.eks_cluster_arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.eks.eks_cluster_version
}

output "eks_cluster_platform_version" {
  description = "Platform version of the EKS cluster"
  value       = module.eks.eks_cluster_platform_version
}

output "eks_cluster_certificate_authority" {
  description = "Base64 encoded certificate authority data"
  value       = module.eks.eks_cluster_certificate_authority
  sensitive   = true
}

output "eks_node_group_id" {
  description = "EKS node group ID"
  value       = module.eks.node_group_id
}

output "eks_node_group_status" {
  description = "Status of the EKS node group"
  value       = module.eks.node_group_status
}

output "eks_cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "eks_oidc_provider_url" {
  description = "URL of the OIDC Provider"
  value       = module.eks.oidc_provider_url
}

output "eks_kubeconfig_command" {
  description = "Command to configure kubectl for the EKS cluster"
  value       = module.eks.kubeconfig_command
}

output "eks_cluster_summary" {
  description = "Complete EKS cluster configuration summary"
  value       = module.eks.eks_cluster_summary
  sensitive   = true
}

# Combined Infrastructure Summary
output "infrastructure_summary" {
  description = "Complete infrastructure deployment summary"
  value = {
    region              = var.aws_region
    environment         = var.environment
    vpc_id              = module.networking.vpc_id
    eks_cluster_name    = module.eks.eks_cluster_name
    eks_endpoint        = module.eks.eks_cluster_endpoint
    ecr_repository_url  = module.ecr.repository_url
    ecr_registry_id     = module.ecr.repository_registry_id
  }
}

# Bedrock Module Outputs
output "bedrock_pod_role_arn" {
  description = "ARN of the IAM role for Bedrock pod access (IRSA)"
  value       = module.bedrock.bedrock_pod_role_arn
}

output "bedrock_pod_role_name" {
  description = "Name of the IAM role for Bedrock pod access"
  value       = module.bedrock.bedrock_pod_role_name
}

output "bedrock_access_policy_arn" {
  description = "ARN of the Bedrock access policy"
  value       = module.bedrock.bedrock_access_policy_arn
}

output "bedrock_vpc_endpoint_bedrock_id" {
  description = "ID of the Bedrock VPC endpoint"
  value       = module.bedrock.bedrock_vpc_endpoint_id
}

output "bedrock_vpc_endpoint_runtime_id" {
  description = "ID of the Bedrock Runtime VPC endpoint"
  value       = module.bedrock.bedrock_runtime_vpc_endpoint_id
}

output "bedrock_security_group_id" {
  description = "Security group ID for Bedrock VPC endpoint"
  value       = module.bedrock.bedrock_security_group_id
}

output "bedrock_irsa_setup_info" {
  description = "Information for setting up IRSA for Bedrock in Kubernetes"
  value       = module.bedrock.bedrock_irsa_setup_info
  sensitive   = true
}

output "bedrock_kubectl_command" {
  description = "kubectl command to create Bedrock service account with IRSA annotation"
  value       = module.bedrock.bedrock_kubectl_command
}

output "bedrock_summary" {
  description = "Complete Bedrock configuration summary"
  value       = module.bedrock.bedrock_summary
}