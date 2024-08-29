resource "helm_release" "kubernetes_dashboard" {
  repository = "https://kubernetes.github.io/dashboard/"
  chart = "kubernetes-dashboard"
  name = "kubernetes-dashboard"
  version = "v6.0.8"
  namespace = "kubernetes-dashboard"
  create_namespace = true

  values = [templatefile("${path.module}/values.yaml", {
    certificate_arn = var.certificate_arn
  })]
  timeout = 3600
}
