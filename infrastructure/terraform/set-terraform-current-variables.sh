#!/bin/bash

export TF_VAR_ca_arn=`terraform output -raw eks_ca_arn` && echo $TF_VAR_ca_arn
export TF_VAR_eks_cluster_production_name=`terraform output -raw eks_cluster_production_name` && echo $TF_VAR_eks_cluster_production_name
export TF_VAR_eks_cluster_staging_name=`terraform output -raw eks_cluster_staging_name` && echo $TF_VAR_eks_cluster_staging_name
export TF_VAR_cicd_appsec_dev_slack_webhook_url=`terraform output -raw cicd_appsec_dev_slack_webhook_url` && echo $TF_VAR_cicd_appsec_dev_slack_webhook_url
export TF_VAR_cicd_appsec_dev_slack_channel=`terraform output -raw cicd_appsec_dev_slack_channel` && echo $TF_VAR_cicd_appsec_dev_slack_channel
export TF_VAR_cicd_appsec_sec_slack_webhook_url=`terraform output -raw cicd_appsec_sec_slack_webhook_url` && echo $TF_VAR_cicd_appsec_sec_slack_webhook_url
export TF_VAR_cicd_appsec_sec_slack_channel=`terraform output -raw cicd_appsec_sec_slack_channel` && echo $TF_VAR_cicd_appsec_sec_slack_channel
export TF_VAR_defectdojo_admin_password=`terraform output -raw defectdojo_admin_password` && echo $TF_VAR_defectdojo_admin_password
