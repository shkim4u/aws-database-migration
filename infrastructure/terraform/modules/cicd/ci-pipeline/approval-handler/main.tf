#locals {
#  aws_codepipeline_pipeline_name = "${var.name}-${local.phase}-pipeline"
#  manual_approval_stage_name = "Approval_Stage"
#  manual_approval_action_name = "Approval_Action"
#}

# For post process.
resource "aws_s3_bucket" "approval_handler" {
  bucket = "${var.name}-${var.phase}-approval-handler-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

data "aws_iam_policy_document" "approval_handler_role_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "approval_handler_role_policy" {
  statement {
    effect = "Allow"
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["codepipeline:*"]
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
      var.post_process_artifact_bucket_arn,
      "${var.post_process_artifact_bucket_arn}/*",
      aws_s3_bucket.approval_handler.arn,
      "${aws_s3_bucket.approval_handler.arn}/*",
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
}

# Role and permission policy for approval handler.
resource "aws_iam_role" "approval_handler" {
  name = "${var.name}-${var.phase}-approval-handler-role"
  assume_role_policy = data.aws_iam_policy_document.approval_handler_role_trust.json
}

resource "aws_iam_role_policy" "approval_handler" {
  name = "${var.name}-${var.phase}-approval-handler-policy"
  role = aws_iam_role.approval_handler.id
  policy = data.aws_iam_policy_document.approval_handler_role_policy.json
}

resource "aws_iam_role_policy_attachment" "approval_handler" {
  for_each = {
    for k, v in {
      AmazonBedrockFullAccess = "${local.iam_role_policy_prefix}/AmazonBedrockFullAccess"
    }: k => v if true
  }

  policy_arn = each.value
  role = aws_iam_role.approval_handler.name
}

resource "aws_codebuild_project" "approval_handler" {
  name = "${var.name}-${var.phase}-approval-handler"
  service_role = aws_iam_role.approval_handler.arn

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
      name = "SEC_SLACK_WEBHOOK_URL"
      value = var.sec_slack_webhook_url
    }

    environment_variable {
      name = "SEC_SLACK_CHANNEL"
      value = var.sec_slack_channel
    }

    environment_variable {
      name  = "SEC_SLACK_SEND_BATCH_SIZE"
      value = "1"
    }

    environment_variable {
      name = "AUTO_APPROVE_BY_NVS"
      value = "true"
    }

    environment_variable {
      name = "PIPELINE_NAME"
      value = var.aws_codepipeline_pipeline_name
    }

    environment_variable {
      name = "STAGE_NAME"
      value = var.manual_approval_stage_name
    }

    environment_variable {
      name = "ACTION_NAME"
      value = var.manual_approval_action_name
    }

    environment_variable {
      name  = "NVS_THRESHOLD"
      value = "10"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "approval-handler.yaml"
  }

  description = "Approval handler project for ${var.name}-${var.phase}"
}
