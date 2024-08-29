resource "helm_release" "kiali" {
  repository = "https://kiali.org/helm-charts"
  chart = "kiali-server"
  name = "kiali-server"
  namespace = "istio-system"
  create_namespace = false
  values = [templatefile("${path.module}/values.yaml", {})]
  timeout = 3600
}

# Istio ingress gateway에 접속하는 예제로 Kiali를 사용해보려면 아래 부분을 Uncomment 할 것.
#resource "kubectl_manifest" "kiali" {
#  for_each  = data.kubectl_path_documents.kiali_manifests.manifests
#  yaml_body = each.value
#  depends_on = [helm_release.kiali]
#}

