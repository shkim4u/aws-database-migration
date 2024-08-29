resource "aws_iam_policy" "vpc_cni_metrics_helper" {
  name = "vpc-cni-metrics-helper-${var.cluster_name}"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "cloudwatch:PutMetricData"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  })
}

module "vpc_cni_metrics_helper_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "VPC-CNI-METRICS-HELPER-IRSA"
  role_policy_arns = {
    policy = aws_iam_policy.vpc_cni_metrics_helper.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["kube-system:${var.service_account_name}"]
    }
  }

  tags = {
    Description = "IAM role for AWS VPC CNI metrics helper"
  }
}


/**
 * VPC CNI Metrics Helper
 * - https://github.com/aws/amazon-vpc-cni-k8s/blob/master/charts/cni-metrics-helper/README.md
 */
resource "helm_release" "cni_metrics_helper" {
  repository = "https://aws.github.io/eks-charts"
  chart = "cni-metrics-helper"
  name  = "cni-metrics-helper"
  namespace = "kube-system"
  create_namespace = false
  values = [templatefile("${path.module}/values.yaml", {
    cluster_name = var.cluster_name,
    service_account_name = var.service_account_name,
    service_account_role_arn = module.vpc_cni_metrics_helper_irsa.iam_role_arn
  })]

  timeout = 3600
}
