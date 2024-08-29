# For post process.
resource "aws_s3_bucket" "post_process" {
  bucket = "${var.name}-${var.phase}-post-process-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

## 2. IAM role and policies.
data "aws_iam_policy_document" "post_process_role_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "post_process_role_policy" {
  statement {
    effect = "Allow"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

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
      var.build_artifact_bucket_arn,
      "${var.build_artifact_bucket_arn}/*",
      aws_s3_bucket.post_process.arn,
      "${aws_s3_bucket.post_process.arn}/*",
      var.pipeline_artifact_bucket_arn,
      "${var.pipeline_artifact_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:ListSecrets"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = [
      # Get EKS cluster ARN from the EKS cluster name.
      # Both Staging and Production EKS clusters are allowed for future needs.
      "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}",
      "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name_staging}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      var.eks_cluster_deploy_role_arn,
      var.eks_cluster_deploy_role_arn_staging,
    ]
  }
}

# Role and permission policy for post-process.
resource "aws_iam_role" "post_process" {
  name = "${var.name}-${var.phase}-post-process-role"
  assume_role_policy = data.aws_iam_policy_document.post_process_role_trust.json
}

resource "aws_iam_role_policy" "post_process" {
  name = "${var.name}-${var.phase}-post-process-policy"
  role = aws_iam_role.post_process.id
  policy = data.aws_iam_policy_document.post_process_role_policy.json
}

resource "aws_iam_role_policy_attachment" "post_process" {
  for_each = {
    for k, v in {
      AmazonBedrockFullAccess = "${local.iam_role_policy_prefix}/AmazonBedrockFullAccess"
    }: k => v if true
  }

  policy_arn = each.value
  role = aws_iam_role.post_process.name
}

resource "aws_codebuild_project" "post_process" {
  name = "${var.name}-${var.phase}-post-process"
  service_role = aws_iam_role.post_process.arn

  artifacts {
    # 만약 Build Spec에서 정의되는 Artifact 이름을 유효하게 하고, S3 Prefix 및 객체 이름을 지정할 수 잏게 하려면 "S3" 타입으로 지정하고,
    # Artifact Namespace Type을 "BUILD_ID"로 지정한다.
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-artifacts.html
    type = "CODEPIPELINE"
  }

  cache {
    type = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type = "BUILD_GENERAL1_LARGE"
    image = "aws/codebuild/standard:7.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "DEV_SLACK_WEBHOOK_URL"
      value = var.dev_slack_webhook_url
    }

    environment_variable {
      name = "DEV_SLACK_CHANNEL"
      value = var.dev_slack_channel
    }

    environment_variable {
      name  = "DEV_SLACK_SEND_BATCH_SIZE"
      value = "1"
    }

    environment_variable {
      name = "MOCK_BEDROCK"
      value = "false"
    }

    environment_variable {
      name  = "BEDROCK_REGION"
      value = var.bedrock_region
    }

    environment_variable {
      name = "BEDROCK_MODEL_ID"
      value = var.bedrock_model_id
    }

    ###
    ### ASPM (Application Security Posture Management)에 진단 결과 전송을 위한 환경 변수.
    ###
    # EKS cluster name for staging environment.
    # 이 클러스터에서 DefectDojo ALB (Application Load Balancer)에 대한 DNS 이름을 얻기 위해 사용된다.
    environment_variable {
      name = "CLUSTER_NAME"
      value = var.eks_cluster_name_staging
    }

    # Staging 환경 EKS 클러스터에 배포하기 위한 IAM Role ARN.
    environment_variable {
      name  = "ASSUME_ROLE_ARN"
      value = var.eks_cluster_deploy_role_arn_staging
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "postprocess.yaml"
  }

  description = "Post process project for ${var.name}-${var.phase}"
}
