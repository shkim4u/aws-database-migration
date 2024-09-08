resource "aws_iam_role" "m2m_admin" {
  name               = "m2m-admin"
  path               = "/"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service: [
            "ec2.amazonaws.com",
            "dms.amazonaws.com",
            "dms.ap-northeast-2.amazonaws.com",
            "dms-fleet-advisor.amazonaws.com"
          ]
        }
      },
    ]
  })
#  managed_policy_arns = [data.aws_iam_policy.administrator-policy.arn]
}

resource "aws_iam_role_policy_attachment" "m2m_admin" {
  role = aws_iam_role.m2m_admin.name
  policy_arn = data.aws_iam_policy.administrator-policy.arn
}

resource "aws_iam_instance_profile" "m2m_admin" {
  name = "m2m-admin-instance-profile"
  role = aws_iam_role.m2m_admin.name
  depends_on = [aws_iam_role.m2m_admin]
}
