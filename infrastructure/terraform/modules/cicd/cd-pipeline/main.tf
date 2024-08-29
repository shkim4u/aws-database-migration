### GitOps CodeCommit repository (Production).
resource "aws_codecommit_repository" "configuration_source" {
  repository_name = "${var.name}-configuration"
  description = "Configuration source code repository for ${var.name}"
}

###
### GitOps CodeCommit repository (Staging).
### ArgoCO를 활용한 Pull 기반 GitOps에서만 사용되므로 추가적인 리소스 생성은 필요하지 않음.
###
resource "aws_codecommit_repository" "configuration_source_staging" {
  repository_name = "${var.name}-configuration-staging"
  description = "Configuration source code repository for ${var.name} (staging)"
}

###
### Begin of CodeBuild project, role and related permissions.
###

## 1. S3 bucket.
resource "aws_s3_bucket" "deploy" {
  bucket = "${var.name}-${local.phase}-deploy-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

## 2. IAM role and policies.
data "aws_iam_policy_document" "deploy_role_trust" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "deploy_role_policy" {
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
      aws_s3_bucket.deploy.arn,
      "${aws_s3_bucket.deploy.arn}/*",
      aws_s3_bucket.pipeline_artifact.arn,
      "${aws_s3_bucket.pipeline_artifact.arn}/*"
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
}

resource "aws_iam_role" "deploy" {
  name = "${var.name}-${local.phase}-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.deploy_role_trust.json
}

resource "aws_iam_role_policy" "deploy" {
  name = "${var.name}-${local.phase}-deploy-policy"
  role = aws_iam_role.deploy.id
  policy = data.aws_iam_policy_document.deploy_role_policy.json
}

## Allow deploy CodeBuild project to have AdministratorAccess.
## Restrict with least privilege when ready or needed.
resource "aws_iam_role_policy_attachment" "deploy" {
  for_each = {
    for k, v in {
      AdministratorAccess = "${local.iam_role_policy_prefix}/AdministratorAccess"
#      AWSLambda_FullAccess = "${local.iam_role_policy_prefix}/AWSLambda_FullAccess",
#      AmazonAPIGatewayAdministrator = "${local.iam_role_policy_prefix}/AmazonAPIGatewayAdministrator",
#      AmazonSSMFullAccess = "${local.iam_role_policy_prefix}/AmazonSSMFullAccess",
#      AWSCodeCommitPowerUser = "${local.iam_role_policy_prefix}/AWSCodeCommitPowerUser",
    }: k => v if true
  }
  policy_arn = each.value
  role = aws_iam_role.deploy.name
}

## 3. CodeBuild.
resource "aws_codebuild_project" "deploy" {
  name = "${var.name}-${local.phase}-deploy"
  service_role = aws_iam_role.deploy.arn

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
      name = "ASSUME_ROLE_ARN"
      value = var.eks_cluster_deploy_role_arn
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "deployspec.yaml"  # CDK: deployspec.yml, Terraform: deployspec.yaml
  }

  description = "Build project for ${var.name}-${local.phase}"
}

###
### End of of CodeBuild project, role and related permissions.
###

## S3 bucket for CodePipeline artifact.
resource "aws_s3_bucket" "pipeline_artifact" {
  # Ensure bucket name length less than or equal to 63 characters.
  bucket = "ppln-artifact-${var.name}-${local.phase}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

###
### Begin of CodePipeline role and related permission.
##
data "aws_iam_policy_document" "pipeline_role_trust" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# References
# - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline
data "aws_iam_policy_document" "pipeline_role_policy" {
  statement {
    effect  = "Allow"
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
      aws_codecommit_repository.configuration_source.arn
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

  statement {
    effect = "Allow"
    actions = ["ecr:*"]
    resources = [var.ecr_repository_arn]
  }
}

resource "aws_iam_role" "pipeline" {
  name               = "${var.name}-${local.phase}-pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_role_trust.json
}

resource "aws_iam_role_policy" "pipeline" {
  name = "${var.name}-${local.phase}-pipeline-policy"
  role = aws_iam_role.pipeline.id
  policy = data.aws_iam_policy_document.pipeline_role_policy.json
}
###
### End of CodePipeline role and related permission.
###

resource "aws_codepipeline" "pipeline" {
  name = "${var.name}-${local.phase}-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source_Stage"

    # CodeCommit action: https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-CodeCommit.html
    action {
      name     = "Pull_Configuration_Source_Action"
      category = "Source"
      owner    = "AWS"
      provider = "CodeCommit"
      version  = "1"
      output_artifacts = ["ConfigurationSourceOutput"]
      configuration = {
        RepositoryName = aws_codecommit_repository.configuration_source.repository_name
        BranchName = "main"
      }
    }

    # ECR action: https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-ECR.html
    action {
      name     = "Pull_Image_Action"
      category = "Source"
      owner    = "AWS"
      provider = "ECR"
      version  = "1"
      output_artifacts = ["EcrSourceOutput"]
      configuration = {
        RepositoryName = var.ecr_repository_name
        ImageTag = "latest"
#        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Deploy_Stage"
    action {
      name     = "Deploy_Action"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts = ["ConfigurationSourceOutput", "EcrSourceOutput"]
      output_artifacts = ["DeployOutput"]
      run_order = 1

      configuration = {
        ProjectName = aws_codebuild_project.deploy.id
        PrimarySource = "ConfigurationSourceOutput"
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
  description = "${var.name} - CodePipeline (CD) Trigger Execution Policy"
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

###
### Begin of ECR Source Action Event.
### Refer: https://github.com/hashicorp/terraform-provider-aws/issues/7012
###
resource "aws_cloudwatch_event_rule" "image_push" {
  name = "${var.name}-${local.phase}-ecr-image-push"
  role_arn = aws_iam_role.cwe_role.arn

  event_pattern = <<EOF
{
  "source": [
    "aws.ecr"
  ],
  "detail": {
    "action-type": [
      "PUSH"
    ],
    "image-tag": [
      "latest"
    ],
    "repository-name": [
      "${var.ecr_repository_name}"
    ],
    "result": [
      "SUCCESS"
    ]
  },
  "detail-type": [
    "ECR Image Action"
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "codepipeline" {
  rule = aws_cloudwatch_event_rule.image_push.name
  target_id = "${var.ecr_repository_name}-Image-Push-Codepipeline"
  arn = aws_codepipeline.pipeline.arn
  role_arn  = aws_iam_role.cwe_role.arn
}

resource "aws_iam_role" "cwe_role" {
  name = "${var.name}-${local.phase}-cwe-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": ["events.amazonaws.com"]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "cwe_policy" {
  name = "${var.name}-${local.phase}-cwe-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "codepipeline:StartPipelineExecution"
        ],
        "Resource": [
            "${aws_codepipeline.pipeline.arn}"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "cws_policy_attachment" {
  name = "${var.name}-${local.phase}-cwe-policy"
  roles = [aws_iam_role.cwe_role.name]
  policy_arn = aws_iam_policy.cwe_policy.arn
}
###
### End of ECR Source Action Event
###
