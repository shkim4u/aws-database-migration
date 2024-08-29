## 1. S3 bucket.
resource "aws_s3_bucket" "build" {
  bucket = "${var.name}-${var.phase}-build-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

## 2. IAM role and policies.
data "aws_iam_policy_document" "build_role_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "build_role_policy" {
  statement {
    effect = "Allow"
    actions = ["cloudformation:*", "iam:*", "ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      #      "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"
      "s3:Abort*",
      "s3:DeleteObject*",
      "s3:GetBucket*",
      "s3:GetObject*",
      "s3:List*",
      "s3:PutObject*",
      #      "s3:PutObjectLegalHold",
      #      "s3:PutObjectRetention",
      #      "s3:PutObjectTagging",
      #      "s3:PutObjectVersionTagging"
    ]
    resources = [
      aws_s3_bucket.build.arn,
      "${aws_s3_bucket.build.arn}/*",
      var.pipeline_artifact_bucket_arn,
      "${var.pipeline_artifact_bucket_arn}/*"
    ]
  }

  #  statement {
  #    effect = "Allow"
  #    actions = [
  #      "ecr:*"
  #    ]
  #    resources = [
  #      "*"
  #    ]
  #  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability", "ecr:PutImage",
      "ecr:InitiateLayerUpload", "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = [var.ecr_repository_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "airflow:CreateCliToken"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "secretsmanager:ListSecrets"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "acm:ListCertificates"
    ]
    resources = ["*"]
  }
}

# Role and permission for build.
resource "aws_iam_role" "build" {
  name = "${var.name}-${var.phase}-build-role"
  assume_role_policy = data.aws_iam_policy_document.build_role_trust.json
}

resource "aws_iam_role_policy" "build" {
  name = "${var.name}-${var.phase}-build-policy"
  role = aws_iam_role.build.id
  policy = data.aws_iam_policy_document.build_role_policy.json
}

resource "aws_iam_role_policy_attachment" "build" {
  for_each = {
    for k, v in {
      AWSLambda_FullAccess = "${local.iam_role_policy_prefix}/AWSLambda_FullAccess",
      AmazonAPIGatewayAdministrator = "${local.iam_role_policy_prefix}/AmazonAPIGatewayAdministrator",
      AmazonSSMFullAccess = "${local.iam_role_policy_prefix}/AmazonSSMFullAccess",
      AWSCodeCommitPowerUser = "${local.iam_role_policy_prefix}/AWSCodeCommitPowerUser",
    }: k => v if true
  }

  policy_arn = each.value
  role = aws_iam_role.build.name
}

#---

## 3. CodeBuild.
resource "aws_codebuild_project" "build" {
  name = "${var.name}-${var.phase}-build"
  service_role = aws_iam_role.build.arn

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
      name = "ECR_REPO_URI"
      value = var.ecr_repository_url
    }
    environment_variable {
      name  = "WEIGHTED_ERRORS"
      value = "10"
    }
    environment_variable {
      name  = "WEIGHTED_WARNINGS"
      value = "3"
    }
    environment_variable {
      name  = "WEIGHTED_NOTES"
      value = "1"
    }
    environment_variable {
      name  = "LOC_SCALER"
      value = "1000"
    }
    environment_variable {
      name  = "NVS_THRESHOLD"
      value = "10"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yaml"  # CDK: buildspec.yml, Terraform: buildspec.yaml
  }

  description = "Build project for ${var.name}-${var.phase}"
}
