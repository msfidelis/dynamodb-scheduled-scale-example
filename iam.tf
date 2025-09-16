
# IAM Role para Application Auto Scaling
resource "aws_iam_role" "dynamodb_autoscaling_role" {
  name = "${var.table_name}-autoscaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Política IAM para Application Auto Scaling
resource "aws_iam_role_policy" "dynamodb_autoscaling_policy" {
  name = "${var.table_name}-autoscaling-policy"
  role = aws_iam_role.dynamodb_autoscaling_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:SetAlarmState",
          "cloudwatch:DeleteAlarms"
        ]
        Resource = "*"
      }
    ]
  })
}