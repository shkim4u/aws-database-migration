module "aws_efs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "AWS-EFS-CSI-IRSA"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["kube-system:${var.service_account_name}"]
    }
  }

  tags = {
    Description = "IAM role for AWS EFS CSI driver"
  }
}

resource "kubernetes_service_account" "efs_csi_controller_sa" {
  metadata {
    name = var.service_account_name
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_efs_csi_irsa.iam_role_arn
    }
  }

  timeouts {
    create = "30m"
  }
}

resource "helm_release" "efs_csi_driver" {
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart = "aws-efs-csi-driver"
  name = "aws-efs-csi-driver"
  namespace = "kube-system"
  create_namespace = false

  values = [templatefile("${path.module}/values.yaml", {
    service_account_name = kubernetes_service_account.efs_csi_controller_sa.metadata.0.name
  })]

  wait = true
  timeout = 3600
}
