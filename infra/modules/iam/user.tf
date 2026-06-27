# create IAM User
resource "aws_iam_user" "mleng_user" {
    name = var.iam_user_name

    tags = {
        Environment = var.environment
        Purpose = "mleng_cicd"
    }
}

# Access key for User
resource "aws_iam_access_key" "mleng_user" {
    user = aws_iam_user.mleng_user.name
    lifecycle {
    create_before_destroy = true
  }
}
