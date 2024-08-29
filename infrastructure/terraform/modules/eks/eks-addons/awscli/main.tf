resource "kubernetes_deployment" "awscli" {
  metadata {
    name = "awscli"
    namespace = "default"
    labels = {
      app = "awscli"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "awscli"
      }
    }
    template {
      metadata {
        labels = {
          app = "awscli"
        }
      }
      spec {
        container {
          image = "amazon/aws-cli"
          name  = "awscli"
          command = ["tail"]
          args = ["-f", "/dev/null"]
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

################################################################################
# IAM Role for Service Account (IRSA)
# This is used by AWSCLI for demonstration.
################################################################################
resource "aws_iam_policy" "awscli_irsa" {
  name = "AWSCLI-IRSA-Policy-${var.eks_cluster_name}"
  path = "/"
  policy = file("${path.module}/awscli-irsa-policy.json")
  description = "IAM policy for AWSCLI demo"
}

module "awscli_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "AWSCLI-IRSA-Role-${var.eks_cluster_name}"

  role_policy_arns = {
    policy = aws_iam_policy.awscli_irsa.arn
  }

  oidc_providers = {
    main = {
      provider_arn = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["default:${var.service_account_name}"]
    }
  }

  tags = {
    Description = "IAM role for AWSCLI demo"
  }

  attach_vpc_cni_policy = false
}

/**
 * [2023-08-27] ServiceAccount
 */
resource "kubernetes_service_account" "awscli_irsa" {
  metadata {
    name = var.service_account_name
    namespace = "default"
    annotations = {
      # [2023-08-27] Testing for cross-account IRSA.
      # Kubernetes OIDC provider should be registered to the target account, eg. Audit account in control tower.
#      "eks.amazonaws.com/role-arn" = "arn:aws:iam::861063945558:role/CronJob-AWSCLI-IRSA-Role"
      "eks.amazonaws.com/role-arn" = module.awscli_irsa.iam_role_arn
    }
  }

  timeouts {
    create = "30m"
  }

#  depends_on = [kubernetes_namespace.batch]
}

resource "kubernetes_deployment" "awscli_irsa" {
  metadata {
    name = "awscli-irsa"
    namespace = "default"
    labels = {
      app = "awscli-irsa"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "awscli-irsa"
      }
    }
    template {
      metadata {
        labels = {
          app = "awscli-irsa"
        }
      }
      spec {
        service_account_name = var.service_account_name
        container {
          image = "amazon/aws-cli"
          name  = "awscli"
          command = ["tail"]
          args = ["-f", "/dev/null"]
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
