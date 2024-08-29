output "m2m_admin_role_arn" {
  description = "M2M admin role ARN"
  value = aws_iam_role.m2m_admin.arn
}

output "m2m_admin_role_name" {
  description = "M2M admin role name"
  value = aws_iam_role.m2m_admin.name
}

output "m2m_admin_ec2_instance_profile_name" {
  description = "M2M admin instance profile"
  value = aws_iam_instance_profile.m2m_admin.name
}
