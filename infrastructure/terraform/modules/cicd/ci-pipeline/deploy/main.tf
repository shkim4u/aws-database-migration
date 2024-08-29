###
### [2023-12-23] KSH: AWS Secrets Manager Secrets for ArgoCD Admin Password.
### (주의) 이 Secrets Manager Secret의 값은 ArgoCD가 "argocd-repo-server" Deployment에서 관리하고,
### ConfigMap "arogcd-secret"에 "bcrypt"를 사용하여 해시값으로 저장되어 있는 값과 연동되지는 않습니다.
### ArgoCD Admin Password를 Secrets Manager와 연동하여 관리하려면 ArgoCD Vault Plugin (AVP)을 활용하여야 하지만 구성이 다소 복잡하므로,
### 수동 연동을 가정하고 구현합니다.
### Secrets Manager에 저장된 값은 CI 파이프라인의 마지막 단계에서 수동 Sync 구성된 ArgoCD Application을 ArgoCD CLI를 호출하여 배포할 때 사용됩니다.
###
resource "random_password" "argocd_admin_password" {
  length = 16
  special = true
  override_special = "_!%^@"
}

resource "aws_secretsmanager_secret" "argocd_admin_password" {
  name = "${var.name}-${var.phase}-argocd-admin-password"
  recovery_window_in_days = 0
  description = "ArgoCD Admin Password for ${var.name}-${var.phase} in EKS Cluster ${var.eks_cluster_name}"
}

#resource "aws_secretsmanager_secret_version" "argocd_admin_password" {
#  secret_id = aws_secretsmanager_secret.argocd_admin_password.id
#  secret_string = random_password.argocd_admin_password.result
#}

# S3 bucket for the artifacts of the CoddeBuild project.
#resource "aws_s3_bucket" "this" {
#  bucket = "${var.name}-${var.phase}-deploy-${data.aws_caller_identity.current.account_id}"
#  force_destroy = true
#}

# Role and permission for deploy with ArgoCD.
data "aws_iam_policy_document" "deploy_role_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "deploy_role_policy" {
  statement {
    effect = "Allow"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

  # TODO: Restrict to only the S3 bucket used for deploy via ArgoCD.
  statement {
    effect = "Allow"
    actions = [
      "s3:Abort*",
      "s3:DeleteObject*",
      "s3:GetBucket*",
      "s3:GetObject*",
      "s3:List*",
      "s3:PutObject*",
    ]
    resources = [
      var.pipeline_artifact_bucket_arn,
      "${var.pipeline_artifact_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = [
      aws_secretsmanager_secret.argocd_admin_password.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = [
      # Get EKS cluster ARN from the EKS cluster name.
      "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "acm:ListCertificates"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      var.eks_cluster_deploy_role_arn,
    ]
  }
}

resource "aws_iam_role" "this" {
  name = "${var.name}-${var.phase}-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.deploy_role_trust.json
}

resource "aws_iam_role_policy" "this" {
  name = "${var.name}-${var.phase}-deploy-policy"
  role = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.deploy_role_policy.json
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = {
    for k, v in {
      AWSCodeCommitPowerUser = "${local.iam_role_policy_prefix}/AWSCodeCommitPowerUser",
    }: k => v if true
  }

  policy_arn = each.value
  role = aws_iam_role.this.name
}

resource "aws_codebuild_project" "deploy" {
  name = "${var.name}-${var.phase}-deploy"
  service_role = aws_iam_role.this.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type = "BUILD_GENERAL1_LARGE"
    image = "aws/codebuild/standard:5.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "CLUSTER_NAME"
      value = var.eks_cluster_name
    }

    environment_variable {
      name = "ECR_REPO_URI"
      value = var.ecr_repository_url
    }

    environment_variable {
      name  = "ARGOCD_ADMIN_PASSWORD_SECRET_ID"
      value = aws_secretsmanager_secret.argocd_admin_password.name
    }

    environment_variable {
      name  = "ARGOCD_APPLICATION_NAME"
      value = var.name
    }

    environment_variable {
      name  = "ASSUME_ROLE_ARN"
      value = var.eks_cluster_deploy_role_arn
    }

    environment_variable {
      name  = "APPLICATION_CONFIGURATION_REPO_URL"
      value = var.application_configuration_repo_url
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "deployspec.yaml"
  }

  description = "Deploy ${var.name}-${var.phase} to EKS Cluster ${var.eks_cluster_name}"
}
