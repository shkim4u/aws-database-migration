variable "name" {}
variable "phase" {}
variable "eks_cluster_name" {}
variable "eks_cluster_name_staging" {}

variable "eks_cluster_deploy_role_arn" {}
variable "eks_cluster_deploy_role_arn_staging" {}

variable "pipeline_artifact_bucket_arn" {}
variable "build_artifact_bucket_arn" {}

variable "dev_slack_webhook_url" {}
variable "dev_slack_channel" {}

variable "ecr_repository_arn" {}
variable "ecr_repository_url" {}

variable "bedrock_region" {
  description = "Bedrock region to use"
  default     = "us-west-2"
}

variable "bedrock_model_id" {
  description = "Bedrock model id to use"
  #  default = "anthropic.claude-v2:1"
  default = "anthropic.claude-3-sonnet-20240229-v1:0"
}
