data "aws_caller_identity" "current" {}

### Karpenter 설정을 위한 Kubernetes 매니페스트 파일 정의 (Just in case)
# Refer: https://registry.terraform.io/providers/alon-dotan-starkware/kubectl/latest/docs/data-sources/kubectl_path_documents
data "kubectl_path_documents" "nodeclass_manifests" {
  pattern = "${path.module}/karpenter-nodeclass/*.yaml"
  vars = {
    cluster_name = module.eks.cluster_name
    cluster_name_prefix = "M2M-EksCluster"
    node_role = "Karpenter-NodeRole-${module.eks.cluster_name}"
  }
}

data "kubectl_path_documents" "nodepool_manifests" {
  pattern = "${path.module}/karpenter-nodepool/*.yaml"
  vars = {
    cluster_name = module.eks.cluster_name
  }
}
