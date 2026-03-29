resource "aws_iam_role" "mleng_role" {
    name = var.iam_role_name
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Sid = "AllowUserAssumption"
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                AWS = [aws_iam_user.mleng_user.arn]
                }
        }]
    })
    tags = {
        Environment = var.environment
        Purpose = "Execution Role"
    }
}