variable "cluster_name" {}
variable "irsa_oidc_provider_arn" {}
variable "service_account_name" {
  default = "cni-metrics-helper-sa"
}

