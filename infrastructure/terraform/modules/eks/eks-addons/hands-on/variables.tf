variable "eks_cluster_name" {}
variable "irsa_oidc_provider_arn" {}
variable "additional_iam_policy_arns" {
  type = list(string)
  default = []
}
variable "certificate_arn" {}
