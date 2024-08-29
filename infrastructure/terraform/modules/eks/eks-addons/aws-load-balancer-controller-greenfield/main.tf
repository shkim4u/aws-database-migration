resource "null_resource" "depends_upon" {
  triggers = {
    depends_on = join("", var.depends_upon)
  }
}

// Reference: https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/aws-load-balancer-controller.html
resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [var.mod_dependency]
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = var.namespace

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller[0].arn
  }

  // v2.5.1 이후 AWS Load Balancer Controller는 기본값으로 Service Type으로 LoadBalancer를 만들면 NLB를 프로비저닝 함.
  // CLB를 만드려면 helm chart value에서 enableServiceMutatorWebhook 값을 false로 설정.
  set {
    name  = "enableServiceMutatorWebhook"
    value = "true"
  }

  values = [
    yamlencode(var.settings)
  ]

  wait = true
  wait_for_jobs = true

  timeout = 3600
}
