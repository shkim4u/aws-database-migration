resource "helm_release" "argo_rollouts" {
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-rollouts"
  name = "argo-rollouts"
  namespace = "argo-rollouts"
  create_namespace = true

  // Refer: https://artifacthub.io/packages/helm/argo/argo-rollouts
  // Use tool to conver JSON to YAML: https://codebeautify.org/json-to-yaml
  values = [templatefile("${path.module}/values.yaml", {})]

  timeout = 3600

}
