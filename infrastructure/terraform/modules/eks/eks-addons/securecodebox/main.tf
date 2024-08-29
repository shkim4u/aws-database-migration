resource "kubernetes_namespace" "securecodebox" {
  metadata {
    name = "securecodebox"
  }
}

resource "helm_release" "securecodebox_operator" {
  repository = "https://charts.securecodebox.io"
  chart = "operator"
  name = "securecodebox-operator"
  namespace = kubernetes_namespace.securecodebox.metadata.0.name
  create_namespace = false
  wait = true
  wait_for_jobs = true
  timeout = 3600
}

resource "helm_release" "securecodebox_zap_advanced" {
  repository = "https://charts.securecodebox.io"
  chart = "zap-advanced"
  name  = "zap-advanced"
  namespace = kubernetes_namespace.securecodebox.metadata.0.name
  create_namespace = false
  wait = true
  wait_for_jobs = true
  timeout = 3600
  depends_on = [helm_release.securecodebox_operator]
}

###
### Persistence Defectdojo Hook.
###
resource "random_integer" "random_port" {
  min = 9001
  max = 9999
}

locals {
  ingress_svc_name      = "defectdojo"
  ingress_svc_namespace = "defectdojo"
  ingress_load_balancer_tags = {
    "elbv2.k8s.aws/cluster"    = var.eks_cluster_name
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "ingress.k8s.aws/stack"    = "${local.ingress_svc_namespace}/${local.ingress_svc_name}"
  }
}

resource "null_resource" "lb_creation" {
  triggers = {
    lb_tags = jsonencode(local.ingress_load_balancer_tags)
  }
}

data "aws_lb" "ingress_load_balancer" {
  depends_on = [null_resource.lb_creation]
  tags = local.ingress_load_balancer_tags
}

# If we have to wait until the ingress ALB is ready, see this:
# https://stackoverflow.com/questions/53125583/terraform-wait-for-classic-load-balancers-a-record.
#resource "null_resource" "patience" {
#  depends_on = [data.aws_lb.ingress_load_balancer]
#  triggers {
#    lb_dns_name = "${data.aws_lb.ingress_load_balancer.dns_name}"
#  }
#
#  provisioner "local-exec" {
#    command = "sleep 10"
#  }
#}

locals {
  defectdojo_token_output_file_name = "defectdojo_token_output_${var.eks_cluster_name}.json"
  defectdojo_token_output_file_path = "${path.module}/${local.defectdojo_token_output_file_name}"
  # If "var.eks_cluster_name" contains "Production"
  defectdojo_endpoint_portfowrad_port = random_integer.random_port.result
#  url = "http://localhost:${local.defectdojo_endpoint_portfowrad_port}/api/v2/api-token-auth/"
  url = "https://${data.aws_lb.ingress_load_balancer.dns_name}/api/v2/api-token-auth/"

#  sha = sha1(join("", [local.url, filesha1(local.defectdojo_token_output_file_name)]))
}

#data "null_data_source" "defectdojo_endpoint" {
#  inputs = {
#    # Reserved.
#    # Instead of using this, we use "http://localhost:${local.defectdojo_endpoint_port}".
##    url = "http://defectdojo-django.defectdojo.svc"
#    url = "http://localhost:${local.defectdojo_endpoint_portfowrad_port}/api/v2/api-token-auth/"
#  }
#}

#output "ingress_dns_name" {
#  value = data.aws_lb.ingress_load_balancer.dns_name
#}

resource "null_resource" "defectdojo_get_token" {
  triggers = {
#    url = data.null_data_source.defectdojo_endpoint.outputs["url"]
#    url = local.url

#    sha = local.sha

#     Trigger with timestamp.
    timestamp = timestamp()
  }

#  provisioner "local-exec" {
#    command = <<EOF
#        export KUBECONFIG="~/.kube/config-${var.eks_cluster_name}"
#        kubectl port-forward svc/defectdojo-django ${local.defectdojo_endpoint_portfowrad_port}:80 -n defectdojo &
#        until $(curl --output /dev/null --silent --head --fail -X POST -H 'content-type: application/json' ${self.triggers.url} -d '{"username": "admin", "password": "${var.defectdojo_admin_password}"}'); do
#          printf '.'
#          sleep 5
#        done
#        curl -X POST -H 'content-type: application/json' ${self.triggers.url} -d '{"username": "admin", "password": "${var.defectdojo_admin_password}"}' > ${local.defectdojo_token_output_file_name}
#        kill -9 %1
#        unset KUBECONFIG
#    EOF
#  }

  provisioner "local-exec" {
    command = <<EOF
        while true; do
          if curl -fsSL -X POST -H 'content-type: application/json' ${local.url} -d '{"username": "admin", "password": "${var.defectdojo_admin_password}"}' -o ${local.defectdojo_token_output_file_name} --insecure; then
            break
          fi
          printf '.'
          sleep 5
        done
    EOF
  }


}

data "local_file" "defectdojo_token_output" {
  filename = local.defectdojo_token_output_file_name
  depends_on = [null_resource.defectdojo_get_token]
}

#output "token" {
#  value = jsondecode(data.local_file.defectdojo_token_output.content)["token"]
#}

data "kubectl_path_documents" "securecodebox_plugins_manifests" {
  pattern = "${path.module}/plugins-manifests/*.yaml"
  vars = {
    # Need to convert to base64.
    username = base64encode("admin")
    apikey = base64encode(jsondecode(data.local_file.defectdojo_token_output.content)["token"])
    namespace = kubernetes_namespace.securecodebox.metadata.0.name
  }
}

#resource "kubectl_manifest" "securecodebox_plugins_resources" {
#  for_each = data.kubectl_path_documents.securecodebox_plugins_manifests.documents
#  yaml_body = each.value
#}

resource "kubectl_manifest" "defectdojo_credentials" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: defectdojo-credentials
      namespace: ${kubernetes_namespace.securecodebox.metadata.0.name}
    type: Opaque
    data:
      username: ${base64encode("admin")}
      apikey: ${base64encode(jsondecode(data.local_file.defectdojo_token_output.content)["token"])}
  YAML
}

resource "helm_release" "securecodebox_persistence_defectdojo" {
  repository = "https://charts.securecodebox.io"
  chart = "persistence-defectdojo"
  name  = "persistence-defectdojo"
  namespace = kubernetes_namespace.securecodebox.metadata.0.name
  create_namespace = false
  wait = true
  wait_for_jobs = true
  timeout = 3600

  set {
    name  = "defectdojo.url"
    value = "http://defectdojo-django.defectdojo.svc"
  }

  depends_on = [helm_release.securecodebox_operator, null_resource.defectdojo_get_token, kubectl_manifest.defectdojo_credentials]
}
