resource "helm_release" "prometheus" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"
  name = "prometheus"
  namespace = "istio-system"
  create_namespace = false
  set {
    name = "ingress.enabled"
    value = true
  }

  timeout = 3600
}
