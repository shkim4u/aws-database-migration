variable "irsa_oidc_provider_arn" {}
variable "service_account_name" {
  # Should be fixed to match with that in lambda/values.yaml
  default = "ack-lambda-controller"
}
variable "eks_cluster_name" {}
