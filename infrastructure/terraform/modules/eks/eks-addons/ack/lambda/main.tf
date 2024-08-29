## References:
## - https://github.com/aws-controllers-k8s/lambda-controller/blob/main/helm/values.yaml
resource "helm_release" "ack_lambda" {
  repository = "oci://public.ecr.aws/aws-controllers-k8s"
  chart = "${local.service}-chart"
  version = "1.3.2"
  name  = "ack-${local.service}-controller"
  namespace = var.namespace
  create_namespace = false

  values = [templatefile("${path.module}/values.yaml", {
    aws_region = data.aws_region.current.name
    service_account_role_arn = var.service_account_role_arn
  })]

  timeout = 3600

}
