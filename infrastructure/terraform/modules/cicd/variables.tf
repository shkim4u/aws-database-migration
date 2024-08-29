# Amazon ECR name.
variable "name" {}

variable "eks_cluster_production_name" {}
variable "eks_cluster_production_admin_role_arn" {}
variable "eks_cluster_production_deploy_role_arn" {}

# [Reserved] EKS cluster for staging.
variable "eks_cluster_staging_name" {}
variable "eks_cluster_staging_admin_role_arn" {}
variable "eks_cluster_staging_deploy_role_arn" {}

variable "cicd_appsec_dev_slack_webhook_url" {}
variable "cicd_appsec_dev_slack_channel" {}
variable "cicd_appsec_sec_slack_webhook_url" {}
variable "cicd_appsec_sec_slack_channel" {}

variable "bedrock_region" {
  description = "Bedrock region to use"
  default     = "us-west-2"
}

variable "bedrock_model_id" {
  description = "Bedrock model id to use"
#  default = "anthropic.claude-v2:1"
  default = "anthropic.claude-3-sonnet-20240229-v1:0"
}
