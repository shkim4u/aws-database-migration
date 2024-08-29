###
### The DAST CodeBuild Project is assumed to be executed in the staging environment.
###
resource "aws_secretsmanager_secret" "argocd_admin_password_staging" {
  name = "${var.name}-${var.phase}-argocd-admin-password-staging"
  recovery_window_in_days = 0
  description = "ArgoCD Admin Password for ${var.name}-${var.phase} in EKS Cluster ${var.eks_cluster_name}"
}

# Role and permission for the DAST CodeBuild Project.
data "aws_iam_policy_document" "dast_role_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "dast_role_permission_policy" {
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
      aws_secretsmanager_secret.argocd_admin_password_staging.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = [
      # Get EKS cluster ARN from the EKS cluster name - would be staging EKS cluster.
      "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"
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
      # Staging 환경 EKS 클러스터에 배포하기 위한 IAM Role ARN.
      var.eks_cluster_deploy_role_arn,
    ]
  }
}

resource "aws_iam_role" "this" {
  name = "${var.name}-${var.phase}-dast"
  assume_role_policy = data.aws_iam_policy_document.dast_role_trust_policy.json
}

resource "aws_iam_role_policy" "this" {
  name = "${var.name}-${var.phase}-dast-policy"
  role = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.dast_role_permission_policy.json
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

resource "aws_codebuild_project" "dast" {
  name         = "${var.name}-${var.phase}-dast"
  service_role = aws_iam_role.this.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "CLUSTER_NAME"
      # DAST를 수행하기 위한 Staging EKS Cluster Name.
      value = var.eks_cluster_name
    }

    # ECR Repository URI for the DAST Image
    # Production 환경과 공유
    environment_variable {
      name  = "ECR_REPO_URI"
      value = var.ecr_repository_url
    }

    # Staging 환경 ArgoCD Admin 암호
    environment_variable {
      name  = "ARGOCD_ADMIN_PASSWORD_SECRET_ID"
      value = aws_secretsmanager_secret.argocd_admin_password_staging.name
    }

    # Staging 환경 ArgoCD 어플리케이션 이름
    environment_variable {
      name  = "ARGOCD_APPLICATION_NAME"
      value = var.name
    }

    # Staging 환경 EKS 클러스터에 배포하기 위한 IAM Role ARN.
    environment_variable {
      name  = "ASSUME_ROLE_ARN"
      value = var.eks_cluster_deploy_role_arn
    }

    # Staging 환경 EKS 클러스터 GitOps 리포지터리 URL.
    environment_variable {
      name  = "APPLICATION_CONFIGURATION_REPO_URL"
      value = var.application_configuration_repo_url
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "dast.yaml"
  }

  description = "DAST for ${var.name}-${var.phase} in EKS Cluster ${var.eks_cluster_name}"
}
