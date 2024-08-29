resource "kubernetes_namespace" "batch" {
  metadata {
    name = local.namespace
    labels = {
      purpose = "batch"
    }
  }
}

## References:
## - https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/
## - https://kubernetes.io/docs/concepts/workloads/controllers/job/
resource "kubernetes_cron_job_v1" "awscli" {
  metadata {
    name = local.name
    namespace = kubernetes_namespace.batch.metadata[0].name
    labels = {
      app = local.name
    }
  }

  spec {
    concurrency_policy = "Replace"
    failed_jobs_history_limit = 5
    schedule = "* * * * *"
#    timezone = "Etc/UTC"
    timezone = "Asia/Seoul"
    starting_deadline_seconds = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit = 2
        ttl_seconds_after_finished = 300
        template {
          metadata {}
          spec {
            container {
              image = "amazon/aws-cli"
              name = local.name
              command = ["aws", "sts", "get-caller-identity"]
            }
          }
        }
      }
    }
  }
}

################################################################################
# IAM Role for Service Account (IRSA)
# This is used by CronJob AWSCLI for demonstration.
################################################################################
resource "aws_iam_policy" "cronjob_awscli_irsa" {
  name = "CronJob-AWSCLI-IRSA_Policy-${var.eks_cluster_name}"
  path = "/"
  policy = file("${path.module}/cronjob-awscli-irsa-policy.json")
  description = "IAM policy for CronJob with AWSCLI demo"
}

module "cronjob_awscli_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "CronJob-AWSCLI-IRSA-Role-${var.eks_cluster_name}"

  role_policy_arns = {
    policy = aws_iam_policy.cronjob_awscli_irsa.arn
  }

  oidc_providers = {
    main = {
      provider_arn = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${var.service_account_name}"]
    }
  }

  tags = {
    Description = "IAM role for CronJob with AWSCLI demo"
  }
}

/**
 * [2023-08-27] ServiceAccount
 */
resource "kubernetes_service_account" "cronjob_awscli_irsa" {
  metadata {
    name = var.service_account_name
    namespace = kubernetes_namespace.batch.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.cronjob_awscli_irsa.iam_role_arn
      # [2023-08-27] Testing for cross-account IRSA.
      # Kubernetes OIDC provider should be registered to the target account, eg. Audit account in control tower.
#      "eks.amazonaws.com/role-arn" = "arn:aws:iam::861063945558:role/CronJob-AWSCLI-IRSA-Role"
    }
  }

  timeouts {
    create = "30m"
  }

  depends_on = [kubernetes_namespace.batch]
}

resource "kubernetes_cron_job_v1" "awscli_irsa" {
  metadata {
    name = "${local.name}-irsa"
    namespace = kubernetes_namespace.batch.metadata[0].name
    labels = {
      app = "${local.name}-irsa"
    }
  }

  spec {
    concurrency_policy = "Replace"
    failed_jobs_history_limit = 5
    schedule = "* * * * *"
    timezone = "Asia/Seoul"
    starting_deadline_seconds = 10
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit = 2
        ttl_seconds_after_finished = 300
        template {
          metadata {}
          spec {
            service_account_name = var.service_account_name
            container {
              image = "amazon/aws-cli"
              name = local.name
#              command = ["aws", "sts", "get-caller-identity"]
              command = ["/bin/bash", "-c"]
#              args = ["aws sts get-caller-identity && aws lambda invoke --function-name domain-protection-accounts-lambda-function response.json && cat response.json"]
              args = ["aws sts get-caller-identity"]
            }
          }
        }
      }
    }
  }
}
