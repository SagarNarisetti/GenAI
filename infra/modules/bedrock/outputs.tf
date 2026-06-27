# modules/bedrock/outputs.tf

output "bedrock_pod_role_arn" {
  description = "ARN of the IAM role for Bedrock pod access (IRSA)"
  value       = aws_iam_role.bedrock_pod_role.arn
}

output "bedrock_pod_role_name" {
  description = "Name of the IAM role for Bedrock pod access"
  value       = aws_iam_role.bedrock_pod_role.name
}

output "bedrock_access_policy_arn" {
  description = "ARN of the Bedrock access policy"
  value       = aws_iam_policy.bedrock_access_policy.arn
}

output "bedrock_access_policy_name" {
  description = "Name of the Bedrock access policy"
  value       = aws_iam_policy.bedrock_access_policy.name
}

output "bedrock_vpc_endpoint_id" {
  description = "ID of the Bedrock VPC endpoint"
  value       = aws_vpc_endpoint.bedrock.id
}

output "bedrock_runtime_vpc_endpoint_id" {
  description = "ID of the Bedrock Runtime VPC endpoint"
  value       = aws_vpc_endpoint.bedrock_runtime.id
}

output "bedrock_security_group_id" {
  description = "Security group ID for Bedrock VPC endpoint"
  value       = aws_security_group.bedrock_vpc_endpoint_sg.id
}

output "bedrock_vpc_endpoint_network_interface_ids" {
  description = "Network interface IDs of the Bedrock VPC endpoint"
  value       = aws_vpc_endpoint.bedrock.network_interface_ids
}

output "bedrock_irsa_setup_info" {
  description = "Information for setting up IRSA for Bedrock in Kubernetes"
  value = {
    namespace              = var.bedrock_namespace
    service_account_name   = var.bedrock_service_account_name
    role_arn               = aws_iam_role.bedrock_pod_role.arn
    oidc_provider_url      = var.oidc_provider_url
  }
  sensitive = true
}

output "bedrock_summary" {
  description = "Complete Bedrock configuration summary"
  value = {
    pod_role_arn                    = aws_iam_role.bedrock_pod_role.arn
    pod_role_name                   = aws_iam_role.bedrock_pod_role.name
    vpc_endpoint_bedrock_id         = aws_vpc_endpoint.bedrock.id
    vpc_endpoint_bedrock_runtime_id = aws_vpc_endpoint.bedrock_runtime.id
    security_group_id               = aws_security_group.bedrock_vpc_endpoint_sg.id
    namespace                       = var.bedrock_namespace
    service_account_name            = var.bedrock_service_account_name
    aws_region                      = var.aws_region
    vpc_id                          = var.vpc_id
  }
}

output "bedrock_irsa_annotation" {
  description = "Kubernetes annotation to add to service account for IRSA"
  value       = "eks.amazonaws.com/role-arn: ${aws_iam_role.bedrock_pod_role.arn}"
}

output "bedrock_kubectl_command" {
  description = "kubectl command to create service account with IRSA annotation"
  value       = "kubectl create serviceaccount ${var.bedrock_service_account_name} -n ${var.bedrock_namespace} && kubectl annotate serviceaccount ${var.bedrock_service_account_name} -n ${var.bedrock_namespace} eks.amazonaws.com/role-arn=${aws_iam_role.bedrock_pod_role.arn}"
}
