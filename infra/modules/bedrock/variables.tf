variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "mleng"
}

variable "environment" {
  description = "Environment name (prod, staging, dev)"
  type        = string
  default     = "prod"
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider (from eks module: oidc_provider_arn)"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC provider (from eks module: oidc_provider_url)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where VPC endpoints will be created (from networking module: vpc_id)"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for VPC endpoints (from networking module: private_subnet_ids)"
  type        = list(string)
}

variable "bedrock_namespace" {
  description = "Kubernetes namespace where Bedrock pods will run"
  type        = string
  default     = "inference"
}

variable "bedrock_service_account_name" {
  description = "Kubernetes service account name bound to IAM role via IRSA"
  type        = string
  default     = "bedrock-sa"
}

variable "aws_region" {
  description = "AWS region where Bedrock models are available (must match cluster region)"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Service = "Bedrock"
    ManagedBy = "Terraform"
  }
}