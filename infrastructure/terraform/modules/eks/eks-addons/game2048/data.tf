#data "aws_eks_cluster" "this" {
#  name = var.cluster_name
#  depends_on = [null_resource.depends_upon]
#}
#
#data "aws_eks_cluster_auth" "this" {
#  name = var.cluster_name
#  depends_on = [null_resource.depends_upon]
#}

# Refer: https://registry.terraform.io/providers/alon-dotan-starkware/kubectl/latest/docs/data-sources/kubectl_path_documents
data "kubectl_path_documents" "namespace" {
  pattern = "${path.module}/namespace/*.yaml"
}

data "kubectl_path_documents" "manifests" {
  pattern = "${path.module}/manifests/*.yaml"
}

data "kubectl_path_documents" "alb" {
  pattern = "${path.module}/alb/*.yaml"
  vars = {
    certificate_arn = var.certificate_arn
  }
}
