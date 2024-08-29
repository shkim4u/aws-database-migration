resource "helm_release" "argocd" {
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  name = "argocd"
  namespace = "argocd"
  create_namespace = true

  // Refer: https://gist.github.com/souzaxx/c59ad91872ea0e9fef00c72b900e32e3
  values = [templatefile("${path.module}/values.yaml", {
    certificate_arn = var.certificate_arn
  })]

  timeout = 3600

}
