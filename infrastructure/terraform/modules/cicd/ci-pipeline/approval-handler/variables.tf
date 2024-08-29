variable "name" {}
variable "phase" {}

variable "pipeline_artifact_bucket_arn" {}
variable "build_artifact_bucket_arn" {}
variable "post_process_artifact_bucket_arn" {}

variable "sec_slack_webhook_url" {}
variable "sec_slack_channel" {}

variable aws_codepipeline_pipeline_name {}
variable manual_approval_stage_name {}
variable manual_approval_action_name {}
