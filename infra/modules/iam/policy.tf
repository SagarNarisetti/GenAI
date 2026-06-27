# managed policy
resource "aws_iam_policy" "mleng_policy" {
    name = var.iam_policy_name
    path = "/"
    description = "IAM Policy for Role MLEngRole"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Sid": "BackendBucketList",
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket"
                ],
                "Resource": "arn:aws:s3:::sagar-mleng-tfstate-backup-bucket"
                },
                {
                "Sid": "BackendStateAccess",
                "Effect": "Allow",
                "Action": [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject"
                ],
                "Resource": [
                    "arn:aws:s3:::sagar-mleng-tfstate-backup-bucket/env/prod/terraform.tfstate",
                    "arn:aws:s3:::sagar-mleng-tfstate-backup-bucket/env/prod/terraform.tfstate.tflock"
                ]
            },
            {
                Sid    = "VPCManagement"
                Effect = "Allow"
                Action = [
                    "ec2:CreateVpc",
                    "ec2:DeleteVpc",
                    "ec2:DescribeVpcs",
                    "ec2:DescribeSubnets",
                    "ec2:CreateSubnet",
                    "ec2:DeleteSubnet",
                    "ec2:CreateNetworkInterface",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:DescribeRouteTables",
                    "ec2:CreateRouteTable",
                    "ec2:DeleteRouteTable",
                    "ec2:AssociateRouteTable",
                    "ec2:DisassociateRouteTable",
                    "ec2:CreateRoute",
                    "ec2:DeleteRoute"
                    ]
                Resource = "*"
            },
            {
                Sid    = "InternetGatewayManagement"
                Effect = "Allow"
                Action = [
                    "ec2:CreateInternetGateway",
                    "ec2:DeleteInternetGateway",
                    "ec2:DescribeInternetGateways",
                    "ec2:AttachInternetGateway",
                    "ec2:DetachInternetGateway"
                    ]
                Resource = "*"
            },
            {
                Sid    = "NATGatewayManagement"
                Effect = "Allow"
                Action = [
                    "ec2:AllocateAddress",
                    "ec2:ReleaseAddress",
                    "ec2:DescribeAddresses",
                    "ec2:CreateNatGateway",
                    "ec2:DeleteNatGateway",
                    "ec2:DescribeNatGateways"
                    ]
                Resource = "*"
            },
            {
                Sid    = "IAMPassRole"
                Effect = "Allow"
                Action = [
                    "iam:PassRole"
                ]
                Resource = aws_iam_role.mleng_role.arn
            },
            {
                Sid    = "AllowAssumeRole"
                Effect = "Allow"
                Action = [
                    "sts:AssumeRole"
                    ]
                Resource = aws_iam_role.mleng_role.arn
            },
            {
                Sid    = "TerraformState"
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject",
                    "s3:ListBucket"
                    ]
                Resource = [
                    "arn:aws:s3:::terraform-state-*",
                    "arn:aws:s3:::terraform-state-*/*"
                    ]
            }

        ]
    })
}

# Attaching policy to the User
resource "aws_iam_user_policy_attachment" "user_policy_attach" {
    user = aws_iam_user.mleng_user.name
    policy_arn = aws_iam_policy.mleng_policy.arn
}

# Attaching policy to the role
resource "aws_iam_role_policy_attachment" "role_policy_attach" {
    role = aws_iam_role.mleng_role.name
    policy_arn = aws_iam_policy.mleng_policy.arn
}