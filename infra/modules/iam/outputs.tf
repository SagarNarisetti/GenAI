# output access key
output "access_key_id" {
  description = "Access key ID"
  value       = aws_iam_access_key.mleng_user.id
  sensitive   = true
}

# output secret access key
output "secret_access_key" {
  description = "Secret access key"
  value       = aws_iam_access_key.mleng_user.secret
  sensitive   = true
}

output "mleng_user_arn" {
    description = "ARN of IAM User"
    value = aws_iam_user.mleng_user.arn
}

output "mleng_user_name" {
    description = "Name of IAM User"
    value = aws_iam_user.mleng_user.name
}

output "mleng_role_arn" {
  description = "ARN of IAM role"
  value       = aws_iam_role.mleng_role.arn
}

output "mleng_role_name" {
  description = "Name of IAM role"
  value       = aws_iam_role.mleng_role.name
}

output "mleng_policy_arn" {
  description = "ARN of managed policy"
  value       = aws_iam_policy.mleng_policy.arn
}

output "mleng_policy_name" {
  description = "Name of IAM policy"
  value = aws_iam_policy.mleng_policy.name
}


# EKS-specific role outputs
output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster service role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_cluster_role_name" {
  description = "Name of the EKS cluster service role"
  value       = aws_iam_role.eks_cluster_role.name
}

output "eks_node_role_arn" {
  description = "ARN of the EKS node group role"
  value       = aws_iam_role.eks_node_role.arn
}

output "eks_node_role_name" {
  description = "Name of the EKS node group role"
  value       = aws_iam_role.eks_node_role.name
}

output "eks_admin_role_arn" {
  description = "ARN of the EKS admin role"
  value       = aws_iam_role.eks_admin_role.arn
}

output "eks_admin_role_name" {
  description = "Name of the EKS admin role"
  value       = aws_iam_role.eks_admin_role.name
}

output "eks_ecr_push_policy_arn" {
  description = "ARN of the EKS ECR push policy"
  value       = aws_iam_policy.eks_ecr_push_policy.arn
}

output "eks_ecr_push_policy_name" {
  description = "Name of the EKS ECR push policy"
  value       = aws_iam_policy.eks_ecr_push_policy.name
}
