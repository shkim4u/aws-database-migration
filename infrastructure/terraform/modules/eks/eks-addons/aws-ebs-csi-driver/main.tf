# Refer: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-eks
module "aws_ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "AWS-EBS-CSI-IRSA"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["kube-system:${var.service_account_name}"]
    }
  }

  tags = {
    Description = "IAM role for AWS EBS CSI driver"
  }
}

resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  metadata {
    name = var.service_account_name
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_ebs_csi_irsa.iam_role_arn
    }
  }

  timeouts {
    create = "30m"
  }
}

resource "helm_release" "ebs_csi_driver" {
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart = "aws-ebs-csi-driver"
  name = "aws-ebs-csi-driver"
  namespace = "kube-system"
  create_namespace = false

  values = [templatefile("${path.module}/values.yaml", {
    service_account_name = kubernetes_service_account.ebs_csi_controller_sa.metadata.0.name
  })]

  wait = true
  timeout = 3600
}
