resource "helm_release" "defectdojo" {
  name  = "defectdojo"
  chart = "${path.module}/django-DefectDojo/helm/defectdojo"
  namespace = "defectdojo"
  create_namespace = true
  dependency_update = true

  set {
      name  = "django.ingress.enabled"
      value = "true"
  }

  set {
        name  = "django.ingress.activateTLS"
        value = "false"
  }

  set {
    name = "createSecret"
    value = "true"
  }

  set {
    name = "createRabbitMqSecret"
    value = "true"
  }

  set {
    name = "createRedisSecret"
    value = "true"
  }

  set {
    name = "createMysqlSecret"
    value = "true"
  }

  set {
    name = "createPostgresqlSecret"
    value = "true"
  }

  set {
    name = "admin.password"
    value = var.admin_password
  }

  values = [templatefile("${path.module}/django-DefectDojo/helm/defectdojo/values.yaml", {
    certificate_arn = var.certificate_arn
  })]

  wait = true
  wait_for_jobs = true
}
