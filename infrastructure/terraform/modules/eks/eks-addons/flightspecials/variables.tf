variable "eks_cluster_name" {}
variable "irsa_oidc_provider_arn" {}
variable "service_account_name" {
  default = "flightspecials-service-account"
}
