module "network" {
  source = "./modules/network"
}

module "iam" {
  source = "./modules/iam"
}

module "ec2" {
  source = "./modules/ec2"
  subnet_id = module.network.public_subnets[0]
  role_name = module.iam.m2m_admin_role_name
  vpc_id = module.network.vpc_id
  instance_profile_name = module.iam.m2m_admin_ec2_instance_profile_name
}

# EKS 클러스터 내의 자원들이 AWS 서비스를 사용할 필요가 있을 때 추가적으로 부여하는 IAM 정책들을 정의합니다.
locals {
  additinal_eks_iam_policy_arns = []
}

module "eks_cluster_production" {
  source = "./modules/eks"
  region = var.region
  vpc_id = module.network.vpc_id
  private_subnet_ids = module.network.private_subnets
  certificate_authority_arn = var.ca_arn
  grafana_admin_password = var.grafana_admin_password
  cluster_name = var.eks_cluster_production_name
  create_karpenter = var.create_karpenter

  defectdojo_admin_password = var.defectdojo_admin_password

  # Additional IAM policy ARNs to be used by the workloads in EKS cluster.
  # Add the ARN of MSK cluster access policy if "create_msk" is true.
  additional_iam_policy_arns = concat(local.additinal_eks_iam_policy_arns, var.create_msk ? [module.msk.0.msk_cluster_access_policy_arn] : [])
}

module "eks_cluster_staging" {
  source = "./modules/eks"
  region = var.region
  vpc_id = module.network.vpc_id
  private_subnet_ids = module.network.private_subnets
  certificate_authority_arn = var.ca_arn
  grafana_admin_password = var.grafana_admin_password
  cluster_name = var.eks_cluster_staging_name
  create_karpenter = var.create_karpenter

  defectdojo_admin_password = var.defectdojo_admin_password

  # Additional IAM policy ARNs to be used by the workloads in EKS cluster.
  # Add the ARN of MSK cluster access policy if "create_msk" is true.
  additional_iam_policy_arns = concat(local.additinal_eks_iam_policy_arns, var.create_msk ? [module.msk.0.msk_cluster_access_policy_arn] : [])
}

###
### CI/CD
###
module "cicd" {
  source = "./modules/cicd"

  for_each = var.cicd_services

  name = each.value
  eks_cluster_production_admin_role_arn = module.eks_cluster_production.cluster_admin_role_arn
  eks_cluster_production_deploy_role_arn = module.eks_cluster_production.cluster_deploy_role_arn
  eks_cluster_production_name = module.eks_cluster_production.cluster_name

  eks_cluster_staging_admin_role_arn = module.eks_cluster_staging.cluster_admin_role_arn
  eks_cluster_staging_deploy_role_arn = module.eks_cluster_staging.cluster_deploy_role_arn
  eks_cluster_staging_name = module.eks_cluster_staging.cluster_name

  cicd_appsec_dev_slack_webhook_url = var.cicd_appsec_dev_slack_webhook_url
  cicd_appsec_dev_slack_channel = var.cicd_appsec_dev_slack_channel
  cicd_appsec_sec_slack_webhook_url = var.cicd_appsec_sec_slack_webhook_url
  cicd_appsec_sec_slack_channel = var.cicd_appsec_sec_slack_channel

  bedrock_region = var.bedrock_region
}


###
### SSM Parameter Store for various information such as container image tag or others.
###
module "ssm" {
  source = "./modules/ssm"
}

###
### RDS database for microservices.
###
module "rds" {
  count = var.create_rds ? 1 : 0
  source = "./modules/rds"
  vpc_id = module.network.vpc_id
  vpc_cidr_block = module.network.vpc_cidr_block
  subnet_ids = module.network.private_subnets
}

###
### MSK cluster.
###
module "msk" {
  count = var.create_msk ? 1 : 0

  source = "./modules/msk"
  vpc_id = module.network.vpc_id
  vpc_cidr_block = module.network.vpc_cidr_block
  subnet_ids = module.network.private_subnets
}

###
### [2024-03-13] Amazon DocumentDB
###
module "documentdb" {
  count = var.create_documentdb ? 1 : 0
  source = "./modules/documentdb"
  vpc_id = module.network.vpc_id
  vpc_cidr_block = module.network.vpc_cidr_block
  subnet_ids = module.network.private_subnets
}

###
### [2023-09-20] Frontend resources - S3 bucket, bucket policy, CloudFront distribution, etc.
###
module "frontend" {
  count = var.create_frontend ? 1 : 0
  source = "./modules/frontend"
}

###
### [2023-11-07] WAFv2
###
module "wafv2" {
  source = "./modules/wafv2"
}
