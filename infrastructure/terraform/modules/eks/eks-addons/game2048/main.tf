#resource "null_resource" "depends_upon" {
#  triggers = {
#    depends_on = join("", var.depends_upon)
#  }
#}

### 아래 이슈 발생으로 "kubectl_manfiest" 객체에 직접 매니페스트 설정으로 진행
# Issues:
# - https://stackoverflow.com/questions/54094575/how-to-run-kubectl-apply-commands-in-terraform
# - https://discuss.hashicorp.com/t/for-each-invalid-argument-values-derived-from-resources-attributes/46693
#resource "kubectl_manifest" "namespace" {
#  for_each  = data.kubectl_path_documents.namespace.manifests
#  yaml_body = each.value
#}

# 1. Namespace.
resource "kubectl_manifest" "namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: game-2048
      labels:
        istio-injection: enabled
  YAML
}

# 2. Deployment.
resource "kubectl_manifest" "deployment" {
  yaml_body = <<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      namespace: game-2048
      name: game-2048
    spec:
      selector:
        matchLabels:
          app.kubernetes.io/name: app-2048
      replicas: 1
      template:
        metadata:
          labels:
            app.kubernetes.io/name: app-2048
        spec:
          containers:
            - image: public.ecr.aws/l6m2t8p7/docker-2048:latest
              imagePullPolicy: Always
              name: app-2048
              ports:
                - containerPort: 80
  YAML

  depends_on = [kubectl_manifest.namespace]
}

# 3. Service.
resource "kubectl_manifest" "service" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Service
    metadata:
      namespace: game-2048
      name: service-2048
    spec:
      ports:
        - port: 80
          targetPort: 80
          protocol: TCP
      type: NodePort
      selector:
        app.kubernetes.io/name: app-2048
  YAML

  depends_on = [kubectl_manifest.deployment]
}

# 4. Virtual gateway.
resource "kubectl_manifest" "gateway" {
  yaml_body = <<-YAML
    apiVersion: networking.istio.io/v1alpha3
    kind: Gateway
    metadata:
      name: gateway-2048
      namespace: game-2048
    spec:
      selector:
        istio: ingressgateway
      servers:
        - port:
            number: 80
            name: http
            protocol: HTTP
          hosts:
            - "*"
  YAML

  depends_on = [kubectl_manifest.service]
}

# 5. Virtual service.
resource "kubectl_manifest" "virtualservice" {
  yaml_body = <<-YAML
    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      name: virtualservice-2048
      namespace: game-2048
    spec:
      hosts:
        - "*"
      gateways:
        - gateway-2048
      http:
        - match:
            - uri:
                prefix: /
          route:
            - destination:
                host: service-2048
                port:
                  number: 80
  YAML
}

# 6. ALB.
resource "kubectl_manifest" "alb" {
  yaml_body = <<-YAML
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: alb-2048
#      namespace: game-2048
      namespace: istio-system
      annotations:
        # create AWS Application LoadBalancer
        kubernetes.io/ingress.class: alb
        # external type
        alb.ingress.kubernetes.io/scheme: internet-facing
        # target type
        #alb.ingress.kubernetes.io/target-type: ip
        # AWS Certificate Manager certificate's ARN
        # alb.ingress.kubernetes.io/certificate-arn: ${var.certificate_arn}
        # open ports 80 and 443
        #alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
        alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
        # redirect all HTTP to HTTPS
        #alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
        # ExternalDNS settings: https://rtfm.co.ua/en/kubernetes-update-aws-route53-dns-from-an-ingress/
    #    external-dns.alpha.kubernetes.io/hostname: "app1-test-common-ingress.example.com, app2-test-common-ingress.example.com"
    spec:
      rules:
        - http:
            paths:
#              - path: /
#                pathType: Prefix
#                backend:
#                  service:
#                    name: ssl-redirect
#                    port:
#                      name: use-annotation
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: istio-ingressgateway
                    port:
                      number: 80
  YAML

  depends_on = [kubectl_manifest.virtualservice]
}

#data "kubectl_filename_list" "namespace" {
#  pattern = "${path.module}/namespace/*.yaml"
#}
#
#resource "kubectl_manifest" "namespace" {
#  count = length(data.kubectl_filename_list.namespace.matches)
#  yaml_body = file(element(data.kubectl_filename_list.namespace.matches, count.index))
#}

###

#resource "kubectl_manifest" "resources" {
#  for_each = data.kubectl_path_documents.manifests.manifests
#  yaml_body = each.value
#  depends_on = [kubectl_manifest.namespace]
#}
#
#resource "kubectl_manifest" "alb" {
#  for_each = data.kubectl_path_documents.alb.manifests
#  yaml_body = each.value
#  depends_on = [kubectl_manifest.resources]
#}
