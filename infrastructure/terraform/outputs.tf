/*
 * Outputs from network resources.
 */
output "network_vpc_id" {
  description = "(Network) VPC ID"
  value = module.network.vpc_id
}

output "network_vpc_cidr_block" {
  description = "(Network) VPC CIDR block"
  value = module.network.vpc_cidr_block
}

output "network_private_subnets_cidr_blocks" {
  description = "(Network) Private subnets CIDR block"
  value = module.network.private_subnets_cidr_blocks
}

output "network_public_subnets_cidr_blocks" {
  description = "(Network) Public subnets CIDR block"
  value = module.network.public_subnets_cidr_blocks
}

output "network_nat_gateway_id_0" {
  description = "(Network) NAT Gateway ID 0"
  value = module.network.nat_gateway_id_0
}

output "network_nat_gateway_id_2" {
  description = "(Network) NAT Gateway ID 1"
  value = module.network.nat_gateway_id_1
}

output "network_nat_gateway_ids" {
    description = "(Network) NAT Gateway IDs"
    value = module.network.nat_gateway_ids
}

/*
 * Outputs from IAM resources.
 */
output "iam_m2m_admin_role_arn" {
  description = "(IAM) M2M admin role ARN"
  value = module.iam.m2m_admin_role_arn
}

output "iam_m2m_admin_ec2_instance_profile" {
  description = "(IAM) M2M admin EC2 instance profile"
  value = module.iam.m2m_admin_ec2_instance_profile_name
}

/*
 * Outputs from EKS resources.
 */
output "eks_cluster_production_name" {
  description = "(EKS) EKS cluster name for production"
  value = module.eks_cluster_production.cluster_name
}

/*
 * Outputs from EKS resources.
 */
output "eks_cluster_staging_name" {
  description = "(EKS) EKS cluster name for staging"
  value = module.eks_cluster_staging.cluster_name
}

output "eks_cluster_production_update_kubeconfig_command" {
  description = "(EKS) Command for aws eks update-kubeconfig for production"
  value = module.eks_cluster_production.update_kubeconfig_command
}

output "eks_cluster_staging_update_kubeconfig_command" {
  description = "(EKS) Command for aws eks update-kubeconfig for staging"
  value = module.eks_cluster_staging.update_kubeconfig_command
}

output "eks_ca_arn" {
  description = "(EKS) Private CA ARN"
  value = module.eks_cluster_production.ca_arn
}


###
### CI/CI
###
output "cicd_appsec_dev_slack_webhook_url" {
  description = "(CICD) Slack webhook URL to notify application vulnerabilities and recommended mitigations for developers (AppSec)"
  value = var.cicd_appsec_dev_slack_webhook_url
}

output "cicd_appsec_dev_slack_channel" {
  description = "(CICD) Slack channel to notify application vulnerabilities and recommended mitigations for developers (AppSec)"
  value = var.cicd_appsec_dev_slack_channel
}

output "cicd_appsec_sec_slack_webhook_url" {
  description = "(CICD) Slack webhook URL to notify high NVS (Normalized Vulnerability Score) alert for security staffs (AppSec)"
  value = var.cicd_appsec_sec_slack_webhook_url
}

output "cicd_appsec_sec_slack_channel" {
  description = "(CICD) Slack channel to notify high NVS (Normalized Vulnerability Score) alert for security staffs (AppSec)"
  value = var.cicd_appsec_sec_slack_channel
}

###
### RDS.
###
output "rds_bastion_instance_id" {
  description = "ID of RDS bastion"
  value = module.ec2.rds_bastion_instance_id
}

output "rds_database_identifier" {
  description = "Identifier of RDS database"
  value = var.create_rds ? module.rds.0.rds_database_identifier : null
}

output "defectdojo_admin_password" {
  description = "DefectDojo admin password"
#  sensitive = true
  value = var.defectdojo_admin_password
}
