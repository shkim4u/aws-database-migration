###
### This is the file that contains some handy resources for general hands-on work, eg. microservice architecture, docker, kubernetes, helm, gitops, etc.
###

### Namespace and service account.
resource "kubernetes_namespace" "network_testing" {
  metadata {
    name = "network-testing"
#    labels = {
#      istio-injection = "enabled"
#    }
  }
}

resource "kubernetes_deployment" "network_multitool" {
  metadata {
    name = "network-multitool"
    namespace = kubernetes_namespace.network_testing.metadata.0.name
    labels = {
      app = "network-multitool"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "network-multitool"
      }
    }
    template {
      metadata {
        labels = {
          app = "network-multitool"
        }
      }
      spec {
        container {
          image = "praqma/network-multitool"
          name  = "network-multitool"
          resources {
            requests = {
              cpu    = "250m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
          }
          image_pull_policy = "IfNotPresent"
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "network_multitool" {
  metadata {
    name = "network-multitool"
    namespace = kubernetes_namespace.network_testing.metadata.0.name
  }

  spec {
    selector = {
      app = kubernetes_deployment.network_multitool.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "network_multitool" {
  metadata {
    name        = "network-multitool-ingress"
    namespace   = kubernetes_namespace.network_testing.metadata.0.name
#    annotations = {
#      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
#      "alb.ingress.kubernetes.io/target-type" = "ip"
#      "alb.ingress.kubernetes.io/listen-ports" = '[{\"HTTP\": 80}, {\"HTTPS\": 443}]'
#      "alb.ingress.kubernetes.io/actions.ssl-redirect" = "'{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}'"
#      "alb.ingress.kubernetes.io/certificate-arn" = var.certificate_arn
#      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
#      "alb.ingress.kubernetes.io/healthcheck-path" = "/"
#      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" = "30"
#      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" = "10"
#      "alb.ingress.kubernetes.io/success-codes" = "200,201,301,302"
#      "alb.ingress.kubernetes.io/target-group-attributes" = "stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=86400"
#    }
    annotations = yamldecode(templatefile("${path.module}/ingress-annotations.yaml", {
      certificate_arn = var.certificate_arn
    }))
  }

  spec {
    ingress_class_name = "alb"
    rule {
      host = "*.ap-northeast-2.elb.amazonaws.com"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.network_multitool.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
