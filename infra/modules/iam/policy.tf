# managed policy
resource "aws_iam_policy" "mleng_policy" {
    name = var.iam_policy_name
    path = "/"
    description = "IAM Policy for Role MLEngRole"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid    = "AllowAssumeRole"
                Effect = "Allow"
                Action = [
                    "sts:AssumeRole"
                    ]
                Resource = aws_iam_role.mleng_role.arn
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