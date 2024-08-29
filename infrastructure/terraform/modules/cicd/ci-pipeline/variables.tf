variable "name" {}

variable "eks_cluster_name" {}
variable "eks_cluster_name_staging" {}
variable "eks_cluster_deploy_role_arn" {}
variable "eks_cluster_deploy_role_arn_staging" {}

variable "ecr_repository_arn" {}
variable "ecr_repository_url" {}

variable "dev_slack_webhook_url" {}
variable "dev_slack_channel" {}

variable "sec_slack_webhook_url" {}
variable "sec_slack_channel" {}

variable "application_configuration_repo_url" {}
variable "application_configuration_repo_url_staging" {}

variable "bedrock_region" {
  description = "Bedrock region to use"
  default     = "us-west-2"
}

variable "bedrock_model_id" {
  description = "Bedrock model id to use"
#  default = "anthropic.claude-v2:1"
  default = "anthropic.claude-3-sonnet-20240229-v1:0"
}
