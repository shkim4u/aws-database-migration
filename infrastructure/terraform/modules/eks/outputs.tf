output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_name" {
  description = "EKS cluster name"
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value = module.eks.cluster_endpoint
}

output "oidc_provider" {
  description = "OIDC provider"
  value = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value = module.eks.oidc_provider_arn
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value = module.eks.cluster_certificate_authority_data
}

output cluster_status {
  value = module.eks.cluster_status
}

output "cluster_admin_role_arn" {
  description = "EKS cluster admin role ARN"
  value = aws_iam_role.cluster_admin.arn
}

output "cluster_deploy_role_arn" {
  description = "EKS cluster deploy role ARN"
  value = aws_iam_role.cluster_deploy.arn
}

output "update_kubeconfig_command" {
  description = "Command to update ~/.kube/config file"
  value = "aws eks update-kubeconfig --name ${var.cluster_name} --alias ${var.cluster_name} --region ${var.region} --role-arn ${aws_iam_role.cluster_admin.arn}"
}

output "ca_arn" {
  description = "Private CA ARN"
  value = module.aws_acm_certificate.ca_arn
}

output "aws_acm_certificate_arn" {
  description = "AWS ACM certificate ARN"
  value = module.aws_acm_certificate.certificate_arn
}
