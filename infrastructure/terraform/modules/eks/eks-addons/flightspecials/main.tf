resource "kubernetes_namespace" "flightspecials" {
  metadata {
    name = local.namespace
    labels = {
      name = local.name
      app = local.app
      purpose = "m2m"
    }
  }
}

resource "aws_iam_policy" "flightspecials_irsa" {
  name = "FlightSpecials-IRSA-Policy-${var.eks_cluster_name}"
  path = "/"
  policy = file("${path.module}/flightspecials-irsa-policy.json")
  description = "IAM policy for FlightSpecials IRSA"
}

module "flightspecials_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "FlightSpecials-IRSA-Role-${var.eks_cluster_name}"

  role_policy_arns = {
    policy = aws_iam_policy.flightspecials_irsa.arn
  }

  oidc_providers = {
    main = {
      provider_arn = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["${kubernetes_namespace.flightspecials.metadata[0].name}:${var.service_account_name}"]
    }
  }

  tags = {
    Description = "IAM role for FlightSpecials"
  }
}

/**
 * [2023-10-08] Service Account
 */
resource "kubernetes_service_account" "flightspecials_irsa" {
  metadata {
    name = var.service_account_name
    namespace = kubernetes_namespace.flightspecials.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.flightspecials_irsa.iam_role_arn
    }
  }

  timeouts {
    create = "30m"
  }
}
