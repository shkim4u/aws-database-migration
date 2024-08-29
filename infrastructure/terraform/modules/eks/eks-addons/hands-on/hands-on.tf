###
### This is the file that contains some handy resources for network testing, to verify various network behaviors of kubernetes networking features for example, pod, service, ingress, and so on.
###

### IAM role and policy.
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "hands_on_pod_identity" {
  name = "HandsOn-Role-PodIdentity-${var.eks_cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "hands_on" {
  # Additional policy ARNs provided from outsed.
  # From the list of "additional_policy_arns", we can attach the policies to the role.
  count = length(var.additional_iam_policy_arns)
  #  name = "m2m-hands-on-policy-attachment-${count.index}"
  policy_arn = var.additional_iam_policy_arns[count.index]
  role = aws_iam_role.hands_on_pod_identity.name
}

### Namespace and service account.
resource "kubernetes_namespace" "hands_on" {
  metadata {
    name = "hands-on"
    labels = {
      istio-injection = "enabled"
    }
  }
}


### Service account and secret.
## Service account for Pod Identity.
# (Note) The "awws_msk_iam_auth" module does not support "Pod Identity" yet.
# Hmm~ Why the hell is the reason that "awws_msk_iam_auth" module does not support "Pod Identity"?
# See this: https://github.com/aws/aws-msk-iam-auth/issues/147
# So, if you want test pod integration with MSK, you need to do so using IRSA (below this section).

# Refer to: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account
resource "kubernetes_service_account" "hands_on_pod_identity" {
  metadata {
    name = "sa-hands-on-pod-identity"
    namespace = kubernetes_namespace.hands_on.metadata.0.name
  }
}

resource "kubernetes_secret" "hands_on_pod_identity" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.hands_on_pod_identity.metadata.0.name
    }
    generate_name = "service-account-token-${kubernetes_service_account.hands_on_pod_identity.metadata.0.name}-"
    namespace = kubernetes_namespace.hands_on.metadata.0.name
  }

  type = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}

### EKS Pod identity.
# Refer to:
# - https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association
resource "aws_eks_pod_identity_association" "hands_on" {
  cluster_name    = var.eks_cluster_name
  namespace       = kubernetes_namespace.hands_on.metadata.0.name
  service_account = kubernetes_service_account.hands_on_pod_identity.metadata.0.name
  role_arn        = aws_iam_role.hands_on_pod_identity.arn
}

### IRSA for hands-on.
locals {
  service_account_name_irsa = "sa-hands-on-irsa"
}

resource "kubernetes_service_account" "hands_on_irsa" {
  metadata {
    name = local.service_account_name_irsa
    namespace = kubernetes_namespace.hands_on.metadata.0.name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.hands_on_irsa.iam_role_arn
    }
  }
}

module "hands_on_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#  version = "~> 5.0"

  role_name = "HandsOn-Role-IRSA-${var.eks_cluster_name}"

  # Assign var.additional_iam_policy_arns to the role using "role_policy_arns"?
  role_policy_arns = { for idx, arn in var.additional_iam_policy_arns : tostring(idx) => arn }
  attach_external_secrets_policy = true

  oidc_providers = {
    main = {
      provider_arn = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["${kubernetes_namespace.hands_on.metadata.0.name}:${local.service_account_name_irsa}"]
    }
  }

  tags = {
    Description = "IAM role for hands-on service account IRSA"
  }

  attach_vpc_cni_policy = false
}

###
### Apache Zipkin for distributes tracing.
###
resource "helm_release" "zipkin" {
  name       = "zipkin-server"
  repository = "https://zipkin.io/zipkin-helm"
  chart      = "zipkin"
  namespace  = kubernetes_namespace.hands_on.metadata.0.name
  version    = "0.3.0"
  create_namespace = false

  values = [templatefile("${path.module}/values.yaml", {
    certificate_arn = var.certificate_arn
  })]

#  wait = true
#  wait_for_jobs = true
}
