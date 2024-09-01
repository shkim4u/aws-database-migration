locals {
  aws_codepipeline_pipeline_name = "${var.name}-${local.phase}-pipeline"
  manual_approval_stage_name = "Approval_Stage"
  manual_approval_action_name = "Approval_Action"
}

## CodeCommit repository.
resource "aws_codecommit_repository" "application_source" {
  repository_name = "${var.name}-application"
  description = "Application source code repository for ${var.name}"
}

###
### Build.
###
module "build_delivery" {
  source = "./build-delivery"

  name                        = var.name
  phase                       = local.phase
  pipeline_artifact_bucket_arn    = aws_s3_bucket.pipeline_artifact.arn
  ecr_repository_url = var.ecr_repository_url
  ecr_repository_arn = var.ecr_repository_arn
}

 module "post_process" {
   source = "./post-process"
   build_artifact_bucket_arn = module.build_delivery.build_artifact_bucket_arn
   dev_slack_channel = var.dev_slack_channel
   dev_slack_webhook_url = var.dev_slack_webhook_url
   ecr_repository_arn = var.ecr_repository_arn
   ecr_repository_url = var.dev_slack_webhook_url
   eks_cluster_deploy_role_arn = var.eks_cluster_deploy_role_arn
   eks_cluster_deploy_role_arn_staging = var.eks_cluster_deploy_role_arn_staging
   eks_cluster_name = var.eks_cluster_name
   eks_cluster_name_staging = var.eks_cluster_name_staging
   name = var.name
   phase = local.phase
   pipeline_artifact_bucket_arn = aws_s3_bucket.pipeline_artifact.arn
 }


###
### [2024-02-14] KSH: DAST (Dynamic Application Security Testing)를 위한 CodeBuild 프로젝트 추가.
###
module "dast" {
  source = "./dast"

  # Staging 환경에서 DAST를 수행한다.
  eks_cluster_deploy_role_arn = var.eks_cluster_deploy_role_arn_staging
  eks_cluster_name            = var.eks_cluster_name_staging
  name = var.name
  phase = local.phase
  pipeline_artifact_bucket_arn = aws_s3_bucket.pipeline_artifact.arn
  application_configuration_repo_url = var.application_configuration_repo_url_staging
  ecr_repository_url = var.ecr_repository_url
}

###
### Approval handler.
###
module "approval_handler" {
  source = "./approval-handler"
  aws_codepipeline_pipeline_name = local.aws_codepipeline_pipeline_name
  build_artifact_bucket_arn = module.build_delivery.build_artifact_bucket_arn
  manual_approval_action_name = local.manual_approval_action_name
  manual_approval_stage_name = local.manual_approval_stage_name
  name = var.name
  phase = local.phase
  pipeline_artifact_bucket_arn = aws_s3_bucket.pipeline_artifact.arn
  post_process_artifact_bucket_arn = module.post_process.post_process_artifact_bucket_arn
  sec_slack_channel = var.sec_slack_channel
  sec_slack_webhook_url = var.sec_slack_webhook_url
}

###
### [2023-12-23] KSH: 배포 CodeBuild 프로젝트 모듈화
###
module "deploy" {
  source = "./deploy"

  eks_cluster_deploy_role_arn = var.eks_cluster_deploy_role_arn
  eks_cluster_name            = var.eks_cluster_name
  name                        = var.name
  phase                       = local.phase
  pipeline_artifact_bucket_arn    = aws_s3_bucket.pipeline_artifact.arn
  application_configuration_repo_url = var.application_configuration_repo_url
  ecr_repository_url = var.ecr_repository_url
}

## S3 bucket for CodePipeline artifact.
resource "aws_s3_bucket" "pipeline_artifact" {
  bucket = "ppln-artifact-${var.name}-${local.phase}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

###
### Begin of CodePipeline role and related permission.
###
data "aws_iam_policy_document" "pipeline_role_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

#resource "aws_s3_bucket_acl" "build_delivery_pipeline_artifact_acl" {
#  bucket = aws_s3_bucket.build_delivery_pipeline_artifact.id
#  acl    = "private"
#}

# References
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline
data "aws_iam_policy_document" "pipeline_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Abort*",
      "s3:DeleteObject*",
      "s3:GetBucket*",
      "s3:GetObject*",
      "s3:List*",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectLegalHold",
      "s3:PutObjectRetention",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging",
    ]
    resources = [
      aws_s3_bucket.pipeline_artifact.arn,
      "${aws_s3_bucket.pipeline_artifact.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:UploadArchive",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:CancelUploadArchive"
    ]

    resources = [
      aws_codecommit_repository.application_source.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "pipeline" {
  name               = "${var.name}-${local.phase}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_role_trust.json
}

resource "aws_iam_role_policy" "pipeline" {
  name   = "${var.name}-${local.phase}-pipeline-policy"
  role   = aws_iam_role.pipeline.id
  policy = data.aws_iam_policy_document.pipeline_role_policy.json
}
###
### End of CodePipeline role and related permission.
###

resource "aws_codepipeline" "pipeline" {
#  name = "${var.name}-${local.phase}-pipeline"
  name = local.aws_codepipeline_pipeline_name
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifact.bucket
    type     = "S3"

#    encryption_key {
#      id   = data.aws_kms_alias.build_delivery_pipeline_artifact.arn
#      type = "KMS"
#    }
  }

  # CodeCommit action: https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeCommit.html
  stage {
    name = "Source_Stage"
    action {
      name = "Pull_Source_Code_Action"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = ["SourceOutput"]
      configuration = {
        RepositoryName = aws_codecommit_repository.application_source.repository_name
        BranchName = "main"
      }
    }
  }

  stage {
    name = "Build_And_Delivery_Stage"
    action {
      name             = "Build_And_Delivery_Action"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"

      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      run_order = 1

      namespace = "Build"

      configuration = {
        ProjectName = module.build_delivery.codebuild_project_id
      }
    }
  }

  # [2023-12-10] Post processing, for example, analyze vulnerability report, acquire remediation actions from GenAI (eg. by calling Bedrock),
  # and send them to communicaton channels (eg. Slack, Teams, etc.)
  # 우리는 이러한 후처리를 Lambda에서 수행할 수도 있지만, 15분이라는 시간 제한을 염두에 두어야 하고, 또 현재로서는 복잡한
  # 구조를 가져갈 필요가 없으므로 일단 단순한 형태인 Pipeline 내의 추가 Stage로서 구현해 본다. (YAGNI)
  stage {
    name = "Post_Process_Stage"
    action {
      name = "Post_Process_Action"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      input_artifacts = ["SourceOutput", "BuildOutput"]
      output_artifacts = ["PostProcessOutput"]
      run_order = 1

      configuration = {
        ProjectName = module.post_process.codebuild_project_id
        PrimarySource = "SourceOutput"
        EnvironmentVariables = jsonencode([
          {
            name = "IMAGE_TAG"
            # Refer to: https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-variables.html
            value = "#{Build.IMAGE_TAG}"
            type = "PLAINTEXT"
          },
          {
            name = "COMMIT_ID"
            value = "#{Build.COMMIT_ID}"
            type = "PLAINTEXT"
          }
        ])
      }
    }
  }

  # [2024-02-14] DAST (Dynamic Application Security Testing)를 위한 Stage 추가.
  stage {
    name = "DAST_Stage"
    action {
      name = "DAST_Action"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      input_artifacts = ["SourceOutput", "BuildOutput"]
      output_artifacts = ["DASTOutput"]
      run_order = 1

      configuration = {
        ProjectName = module.dast.codebuild_project_id
        PrimarySource = "SourceOutput"
        EnvironmentVariables = jsonencode([
          {
            name = "IMAGE_TAG"
            # Refer to: https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-variables.html
            value = "#{Build.IMAGE_TAG}"
            type = "PLAINTEXT"
          },
          {
            name = "COMMIT_ID"
            value = "#{Build.COMMIT_ID}"
            type = "PLAINTEXT"
          }
        ])
      }
    }
  }

  # Add manual approval stage.
  stage {
    name = local.manual_approval_stage_name

    action {
      name = local.manual_approval_action_name
      category = "Approval"
      owner = "AWS"
      provider = "Manual"
      version = "1"
#      input_artifacts = ["PostProcessOutput"]
      run_order = 1
    }

    action {
      name = "Approval_Handler_Action"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      # TODO: Perform stop or go also with DAST result.
      input_artifacts = ["SourceOutput", "BuildOutput", "PostProcessOutput", "DASTOutput"]
      output_artifacts = ["ApprovalHandlerOutput"]
      run_order = 1

      # Set primary source artifact as the first input artifact.
      configuration = {
        ProjectName = module.approval_handler.codebuild_project_id
        PrimarySource = "SourceOutput"
      }
    }
  }

  stage {
    name = "Deploy_Stage"
    action {
      name = "Deploy_Action"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      input_artifacts = ["SourceOutput", "BuildOutput", "ApprovalHandlerOutput"]
      run_order = 1

      configuration = {
        ProjectName = module.deploy.codebuild_project_id
        PrimarySource = "SourceOutput"
        EnvironmentVariables = jsonencode([
          {
            name = "IMAGE_TAG"
            # Refer to: https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-variables.html
            value = "#{Build.IMAGE_TAG}"
            type = "PLAINTEXT"
          },
          {
            name = "COMMIT_ID"
            value = "#{Build.COMMIT_ID}"
            type = "PLAINTEXT"
          }
        ])
      }
    }
  }
}

###
### EventBridge trigger role.
###
resource "aws_iam_role" "pipeline_trigger" {
  name = "${var.name}-${local.phase}-pipeline-trigger-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "pipeline_trigger" {
  description = "${var.name} - CodePipeline (CI) Trigger Execution Policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "codepipeline:StartPipelineExecution"
      ],
      "Effect": "Allow",
      "Resource": "${aws_codepipeline.pipeline.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pipeline_trigger_attach" {
  role       = aws_iam_role.pipeline_trigger.name
  policy_arn = aws_iam_policy.pipeline_trigger.arn
}
