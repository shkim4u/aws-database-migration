variable "region" {
  description = "AWS Region"
  type = string
  default = "ap-northeast-2"
}

// Private CA ARN to be passed to EKS module, which will be used ALB HTTTPS support.
/**
 * CA ARN은 입력하기 위해서는 먼서 Private Certificate Authority를 설정하여야 한다.
 * 참조: eks-cluster-cdk.md
 * Ref: https://developer.hashicorp.com/terraform/language/values/variables
 * CA ARN 변수 설정 방법
 * 1. export TF_VAR_ca_arn=arn:aws:XXX
 * 2. terraform.tfvars 혹은 terraform.tfvars.json 파일에 ca_arn 변수 설정
 * 3. *.auto.tfvars or *.auto.tfvars.json
 * 4. terraform apply -var "ca_arn=arn:aws:" (혹은 -var-file 옵션 사용)
 * 5. 그냥 실행하면 Terraform이 변수 입력 프롬프트 표시하며 이 때 입력
 */
variable "ca_arn" {
  description = "ARN of private certificate authority to create server certificate with"
}

variable "eks_cluster_production_name" {
  description = "The name of EKS cluster to be created for production"
}

variable "eks_cluster_staging_name" {
  description = "The name of EKS cluster to be created for staging"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  default = "P@$$w0rd00#1"
}

variable "create_msk" {
  description = "True or False to exclude Amazon MSK cluster for its longer time to create"
  default = false
}
variable "create_rds" {default = false}
variable "create_frontend" {default = false}
variable "create_karpenter" {default = false}
variable "create_documentdb" {default = false}

variable "cicd_services" {
  description = "Map of CI/CD services"
  type = map(string)
  default = {
    "cicd-flightspecials" = "flightspecials"
    "cicd-hotelspecials" = "hotelspecials"
  }
}

// [2023-12-18] CICD AppSec Slack Webhook URL
variable "cicd_appsec_dev_slack_webhook_url" {
  description = "Slack Webhook URL for Dev"
  default = "not used anymore"
}
variable "cicd_appsec_dev_slack_channel" {
  description = "Slack channel for Dev"
  default = "not used anymore"
}

variable "cicd_appsec_sec_slack_webhook_url" {
  description = "Slack Webhook URL for Sec"
  default = "not used anymore"
}
variable "cicd_appsec_sec_slack_channel" {
  description = "Slack channel for Sec"
  default = "not used anymore"
}

variable "bedrock_region" {
  description = "Bedrock region to use"
  # Workshop studio or event engine only supports us-west-2.
  default     = "us-west-2"
}

variable "bedrock_model_id" {
  description = "Bedrock model id to use"
  #  default = "anthropic.claude-v2:1"
  default = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "defectdojo_admin_password" {
  description = "Admin password for DefectDojo"
  default = "Abraca00#1"
}
