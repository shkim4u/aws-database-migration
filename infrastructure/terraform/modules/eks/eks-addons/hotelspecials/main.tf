resource "kubernetes_namespace" "hotelspecials" {
  metadata {
    name = local.namespace
    labels = {
      name = local.name
      app = local.app
      purpose = "m2m"
    }
  }
}

resource "aws_iam_policy" "hotelspecials_irsa" {
  name = "HotelSpecials-IRSA-Policy-${var.eks_cluster_name}"
  path = "/"
  policy = file("${path.module}/hotelspecials-irsa-policy.json")
  description = "IAM policy for HotelSpecials IRSA"
}

module "hotelspecials_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "HotelSpecials-IRSA-Role-${var.eks_cluster_name}"

  role_policy_arns = {
    policy = aws_iam_policy.hotelspecials_irsa.arn
  }

  oidc_providers = {
    main = {
      provider_arn = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["${kubernetes_namespace.hotelspecials.metadata[0].name}:${var.service_account_name}"]
    }
  }

  tags = {
    Description = "IAM role for HotelSpecials"
  }
}

/**
 * [2023-10-08] Service Account
 */
resource "kubernetes_service_account" "hotelspecials_irsa" {
  metadata {
    name = var.service_account_name
    namespace = kubernetes_namespace.hotelspecials.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.hotelspecials_irsa.iam_role_arn
    }
  }

  timeouts {
    create = "30m"
  }
}
