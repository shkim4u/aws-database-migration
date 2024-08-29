# Get the policy by name
data "aws_iam_policy" "administrator-policy" {
  name = "AdministratorAccess"
}
