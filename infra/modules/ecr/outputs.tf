# modules/ecr/outputs.tf

output "repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.ecr_repo.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.ecr_repo.arn
}

output "repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.ecr_repo.name
}

output "repository_registry_id" {
  description = "Registry ID (AWS Account ID) where the repository is stored"
  value       = aws_ecr_repository.ecr_repo.registry_id
}

output "lifecycle_policy_text" {
  description = "Lifecycle policy applied to the repository"
  value       = aws_ecr_lifecycle_policy.ecr_repo_lifecycle_policy.policy
}

# Docker login command
output "docker_login_command" {
  description = "Command to login to ECR repository"
  value       = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.ecr_repo.repository_url}"
  sensitive   = true
}

# Push command template
output "docker_push_command" {
  description = "Template command to push images to ECR"
  value       = "docker tag <image>:<tag> ${aws_ecr_repository.ecr_repo.repository_url}:<tag> && docker push ${aws_ecr_repository.ecr_repo.repository_url}:<tag>"
}

# Data source for current region
data "aws_region" "current" {}

# Summary output
output "ecr_summary" {
  description = "ECR repository configuration summary"
  value = {
    repository_url    = aws_ecr_repository.ecr_repo.repository_url
    repository_arn    = aws_ecr_repository.ecr_repo.arn
    repository_name   = aws_ecr_repository.ecr_repo.name
    registry_id       = aws_ecr_repository.ecr_repo.registry_id
    image_mutability  = aws_ecr_repository.ecr_repo.image_tag_mutability
    scan_on_push      = aws_ecr_repository.ecr_repo.image_scanning_configuration[0].scan_on_push
  }
}