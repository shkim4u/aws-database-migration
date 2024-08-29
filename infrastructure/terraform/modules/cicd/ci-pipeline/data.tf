data "aws_partition" "current" {}
data "aws_caller_identity" "current" {} # data.aws_caller_identity.current.account_id
data "aws_region" "current" {} # data.aws_region.current.name

#data "aws_kms_alias" "build_delivery_pipeline_artifact" {
#  name = "alias/BuildDeliveryPipelineArtifact"
#}
