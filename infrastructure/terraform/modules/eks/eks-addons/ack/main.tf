resource "kubernetes_namespace" "ack" {
  metadata {
    name = local.namespace
    labels = {
      purpose = "aws-controller-kubernetes"
    }
  }
}

## References
## - Required IRSA: https://aws-controllers-k8s.github.io/community/docs/user-docs/irsa/
/**
# Download the recommended managed and inline policies and apply them to the
# newly created IRSA role

export SERVICE=lambda
export RELEASE_VERSION=$(curl -sL https://api.github.com/repos/aws-controllers-k8s/${SERVICE}-controller/releases/latest | jq -r '.tag_name | ltrimstr("v")')

BASE_URL=https://raw.githubusercontent.com/aws-controllers-k8s/${SERVICE}-controller/main
echo $BASE_URL

POLICY_ARN_URL=${BASE_URL}/config/iam/recommended-policy-arn
echo $POLICY_ARN_URL

POLICY_ARN_STRINGS="$(wget -qO- ${POLICY_ARN_URL})"
echo $POLICY_ARN_STRINGS
# (참고) 람다는 위 환경변수에 값이 없음, 즉, Managed Policy가 정의되어 있지 않음.

INLINE_POLICY_URL=${BASE_URL}/config/iam/recommended-inline-policy
echo $INLINE_POLICY_URL

INLINE_POLICY="$(wget -qO- ${INLINE_POLICY_URL})"
echo $INLINE_POLICY

while IFS= read -r POLICY_ARN; do
echo -n "Attaching $POLICY_ARN ... "
aws iam attach-role-policy \
--role-name "${ACK_CONTROLLER_IAM_ROLE}" \
--policy-arn "${POLICY_ARN}"
echo "ok."
done <<< "$POLICY_ARN_STRINGS"

if [ ! -z "$INLINE_POLICY" ]; then
echo -n "Putting inline policy ... "
aws iam put-role-policy \
--role-name "${ACK_CONTROLLER_IAM_ROLE}" \
--policy-name "ack-recommended-policy" \
--policy-document "$INLINE_POLICY"
echo "ok."
fi
*/

################################################################################
# IAM Role for Service Account (IRSA)
# This is used by ACK lambda controller.
################################################################################
resource "aws_iam_policy" "ack_lambda_controller_irsa" {
  name = "ACK-Lambda-IRSA_Policy-${var.eks_cluster_name}"
  path = "/"
  policy = file("${path.module}/lambda/ack-lambda-irsa-policy.json")
  description = "IAM policy for ACK Lambda controller"
}

module "ack_lambda_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "ACK-Lambda-IRSA-Role-${var.eks_cluster_name}"

  role_policy_arns = {
    policy = aws_iam_policy.ack_lambda_controller_irsa.arn
  }

  oidc_providers = {
    main = {
      provider_arn = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${var.service_account_name}"]
    }
  }

  tags = {
    Description = "IAM role for ACK Lambda controller"
  }
}

# 서비스 어카운트는 lambda/values.yaml에 정의되어 있으므로 이를 통해 만들어짐
#resource "kubernetes_service_account" "ack_lambda_controller_irsa" {
#  metadata {
#    name = var.service_account_name
#    namespace = kubernetes_namespace.ack.metadata[0].name
#    annotations = {
#      "eks.amazonaws.com/role-arn" = module.ack_lambda_controller_irsa.iam_role_arn
#    }
#  }
#
#  timeouts {
#    create = "30m"
#  }
#
##  depends_on = [kubernetes_namespace.batch]
#}

module "ack_lambda" {
  source = "./lambda"
  namespace = kubernetes_namespace.ack.metadata[0].name
#  service_account_role_arn = "arn:aws:iam::861063945558:role/aws-controller-kubernetes-lambda"
  service_account_role_arn = module.ack_lambda_controller_irsa.iam_role_arn
}
