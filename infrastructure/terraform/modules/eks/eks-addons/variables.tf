variable "region" {}
variable "eks_cluster_name" {}
variable "eks_cluster_endpoint" {}
variable "cluster_certificate_authority_data" {}
variable "oidc_provider" {}
variable "oidc_provider_arn" {}
variable "aws_acm_certificate_arn" {}
variable "grafana_admin_password" {}
variable "create_karpenter" {default = false}

variable "defectdojo_admin_password" {}

variable "additional_iam_policy_arns" {
  type = list(string)
  default = []
}
