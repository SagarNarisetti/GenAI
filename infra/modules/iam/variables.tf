### IAM User Role and Policy Variables
variable "iam_user_name" {
    description = "Name of IAM User"
    type = string
}

variable "iam_role_name" {
    description = "Name of IAM Role"
    type = string
}

variable "iam_policy_name" {
    description = "Name of IAM Policy"
    type = string
}

variable "environment" {
    description = "Name of Environment"
    type = string
    default = "prod"
}

variable "eks_cluster_role_name" {
    description = "Name of the IAM role for the EKS cluster"
    type = string
}

variable "eks_node_role_name" {
    description = "Name of the IAM role for EKS nodes"
    type = string
}

variable "eks_admin_role_name" {
    description = "Name of the admin IAM role for EKS cluster access"
    type = string
}

variable "eks_ecr_push_policy" {
    description = "Name of the IAM policy for EKS nodes to push images to ECR"
    type = string
}

# variable "mleng_user_arn" {
#   description = "ARN of the IAM user for EKS cluster access provided from the root or another module"
#   type        = string
# }

# variable "cluster_role_arn" {
#   description = "ARN of the IAM role for the EKS cluster"
#   type        = string
# }

# variable "node_role_arn" {
#   description = "ARN of the IAM role for EKS nodes"
#   type        = string
# }

# variable "eks_admin_role_arn" {
#   description = "ARN of the admin IAM role for EKS cluster access"
#   type        = string
# }
