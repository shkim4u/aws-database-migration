resource "null_resource" "depends_upon" {
  triggers = {
    depends_on = join("", var.depends_upon)
  }
}

# Wait for AWS load balancer controller ready.
#resource "time_sleep" "wait_2_minutes" {
#  create_duration = "120s"
#}

resource "helm_release" "cert_manager" {
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  name = "cert-manager"
  namespace = "cert-manager"
  create_namespace = true
  version = "v1.12.3"
  set {
    name = "installCRDs"
    value = true
  }
  wait = true
  wait_for_jobs = true

#  depends_on = [null_resource.depends_upon, time_sleep.wait_2_minutes]
  depends_on = [null_resource.depends_upon]

  timeout = 3600
}
