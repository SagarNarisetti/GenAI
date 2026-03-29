output "user_arn" {
    description = "ARN of IAM User"
    value = aws_iam_user.mleng_user.arn
}

output "user_name" {
    description = "Name of IAM User"
    value = aws_iam_user.mleng_user.name
}

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

output "role_arn" {
  description = "ARN of IAM role"
  value       = aws_iam_role.mleng_role.arn
}

output "role_name" {
  description = "Name of IAM role"
  value       = aws_iam_role.mleng_role.name
}

output "policy_arn" {
  description = "ARN of managed policy"
  value       = aws_iam_policy.mleng_policy.arn
}