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

output "iam_user_arn" {
  description = "ARN of IAM user"
  value = module.iam.user_arn
}

output "iam_user_name" {
  description = "Name of IAM user"
  value = module.iam.user_name
}

output "iam_role_arn" {
  description = "ARN of IAM role"
  value = module.iam.role_arn
}

output "iam_role_name" {
  description = "Name of IAM role"
  value = module.iam.role_name
}

output "iam_policy_arn" {
  description = "ARN of IAM policy"
  value = module.iam.policy_arn
}

output "iam_policy_name" {
  description = "Name of IAM policy"
  value = module.iam.policy_name
}