
# IAM Role for Bedrock Service Account (IRSA)
# This role is assumed by Kubernetes pods via the OIDC provider
resource "aws_iam_role" "bedrock_pod_role" {
  name        = "${var.project_name}-bedrock-pod-role"
  description = "IAM role for Kubernetes pods to access Bedrock via IRSA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPodAssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.bedrock_namespace}:${var.bedrock_service_account_name}"
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-bedrock-pod-role"
      Namespace   = var.bedrock_namespace
      ServiceAccount = var.bedrock_service_account_name
      Environment = var.environment
    }
  )
}

# Policy for Bedrock Access
resource "aws_iam_policy" "bedrock_access_policy" {
  name        = "${var.project_name}-bedrock-access-policy"
  description = "Policy for pods to invoke Bedrock models"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockModelInvocation"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "arn:aws:bedrock:${var.aws_region}::foundation-model/*"
      },
      {
        Sid    = "BedrockModelList"
        Effect = "Allow"
        Action = [
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel"
        ]
        Resource = "*"
      },
      {
        Sid    = "BedrockAgents"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeAgent",
          "bedrock:GetAgent",
          "bedrock:ListAgents"
        ]
        Resource = "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:agent/*"
      },
      {
        Sid    = "BedrockKnowledgeBase"
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate",
          "bedrock:ListKnowledgeBases",
          "bedrock:GetKnowledgeBase"
        ]
        Resource = "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-bedrock-access-policy"
      Environment = var.environment
    }
  )
}

# Attach Bedrock policy to pod role
resource "aws_iam_role_policy_attachment" "bedrock_access_attach" {
  role       = aws_iam_role.bedrock_pod_role.name
  policy_arn = aws_iam_policy.bedrock_access_policy.arn
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get current AWS region
data "aws_region" "current" {}

# Security Group for Bedrock Endpoint (if needed for VPC endpoint)
resource "aws_security_group" "bedrock_vpc_endpoint_sg" {
  name_prefix = "${var.project_name}-bedrock-"
  description = "Security group for Bedrock VPC endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS access to Bedrock VPC Endpoint"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-bedrock-vpc-endpoint-sg"
      Environment = var.environment
    }
  )
}

# Bedrock VPC Endpoint (optional - for private access without NAT)
resource "aws_vpc_endpoint" "bedrock" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.bedrock"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.bedrock_vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-bedrock-vpc-endpoint"
      Environment = var.environment
    }
  )
}

# Bedrock Runtime VPC Endpoint (for invoke operations)
resource "aws_vpc_endpoint" "bedrock_runtime" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.bedrock-runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.bedrock_vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-bedrock-runtime-vpc-endpoint"
      Environment = var.environment
    }
  )
}
