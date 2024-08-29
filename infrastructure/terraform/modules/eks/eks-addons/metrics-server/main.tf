resource "helm_release" "metrics_server" {
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart = "metrics-server"
  name  = "metrics-server"
  namespace = "kube-system"
  create_namespace = false
  timeout = 3600
}
