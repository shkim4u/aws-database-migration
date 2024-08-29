data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
  depends_on = [null_resource.depends_upon]
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
  depends_on = [null_resource.depends_upon]
}
