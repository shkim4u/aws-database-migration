###
### EKS admin role.
###
resource "aws_iam_role" "cluster_admin" {
  name = "${var.cluster_name}-AdminRole"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })

  # This is IAM Policy with Full Access to EKS Configuration
  inline_policy {
    name = "eks-full-access-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "eks:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  tags = {
    description = "Administrator role for EKS cluster"
  }
}

###
### EKS deploy role supposed to be used in deploy pipeline.
###
resource "aws_iam_role" "cluster_deploy" {
  name = "${var.cluster_name}-DeployRole"
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })

  # This is IAM Policy with Full Access to EKS Configuration
  inline_policy {
    name = "AdministratorAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  tags = {
    description = "Role for deployment pipeline toward EKS cluster. Restrict to least-privileged when ready."
  }
}

###
### EKS custer.
###
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = var.cluster_name
  cluster_version = var.cluster_version

  iam_role_use_name_prefix = false

  kms_key_deletion_window_in_days = 7

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true

  # Lis of Amazon EKS add-ons to enable.
  # Refer to: https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html#workloads-add-ons-available-eks
  # aws eks describe-addon-versions --kubernetes-version 1.29 --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' --output table
  # coredns, kube-proxy, vpc-cni, aws-ebs-csi-driver, aws-efs-csi-driver, amazon-cloudwatch-observability, eks-pod-identity-agent
  cluster_addons = {
    # [2024-02-24] Why the hell this has gone?
    amazon-cloudwatch-observability = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  vpc_id = var.vpc_id
  subnet_ids = var.private_subnet_ids

  enable_irsa = true

  // Create master role for the EKS cluster.
  create_iam_role = true
  iam_role_name = "${var.cluster_name}-ClusterRole"

  # Probably combined to "authentication_mode=API_AND_CONFIG_MAP".
  # Refer to: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  # 릴리즈 노트 (Terraform AWS EKS Module > 20.0.0): https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-20.0.md
  # 업그레이드 가이드: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-20.0.md
  enable_cluster_creator_admin_permissions = true
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    cluster_admin = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.cluster_admin.arn
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    },
    deploy_admin = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.cluster_deploy.arn
      policy_associations = {
        deploy_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    },
  }

  // Managed node group.
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    disk_size = 100
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
      CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      AutoscalingFullAccess = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
    }
  }

  eks_managed_node_groups = {
    "OnDemand" = {
      capacity_type  = "ON_DEMAND"
      instance_types = ["m5.4xlarge"]
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      # 생성된 node에 labels 추가 (kubectl get nodes --show-labels로 확인 가능)
      labels         = {
        ondemand = "true"
      }
      update_config = {
        # Refer to: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group
        # This is the default.
        "max_unavailable_percentage": 33
        #        "max_unavailable" = "1"
      }
      force_update_version = true
    }

    # For future use.
    # Refer to: https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/986
    #    block_device_mappings = [
    #      {
    #        device_name = "/dev/xvda"
    #        volume_type = "gp3"
    #        volume_size = 50
    #        delete_on_termination = true
    #        io1 = 3000
    #        throughput = 125
    #      },
    #      {
    #        device_name           = "/dev/xvdf" # mount point to /local1 (it could be local2, depending upon the disks are attached during boot)
    #        volume_type           = "gp3" # The volume type. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp3).
    #        volume_size           = 50
    #        delete_on_termination = true
    ##        encrypted             = true
    ##        kms_key_id            = "" # Custom KMS Key can be used to encrypt the disk
    #        iops                  = 3000
    #        throughput            = 125
    #      }
    #    ]
  }

  node_security_group_additional_rules = {
    # Refer: https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/619
    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed
    ingress_cluster_to_node_all_traffic = {
      description              = "Cluster API to Nodegroup all traffic"
      protocol                 = "-1"
      from_port                = 0
      to_port                  = 0
      type                     = "ingress"
      source_security_group_id = module.eks.cluster_security_group_id
    }

    // Istio Ingress Gateway 80, 443에 대한 허용
    ingress_node_to_node_http_traffic = {
      description              = "Node-to-Node traffic for HTTP"
      protocol                 = "tcp"
      from_port                = 80
      to_port                  = 80
      type                     = "ingress"
      source_security_group_id = module.eks.node_security_group_id
    }
    ingress_node_to_node_https_traffic = {
      description              = "Node-to-Node traffic for HTTPS"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = module.eks.node_security_group_id
    }
  }

  # Configure node security group tags for Karpenter later.
  node_security_group_tags = {}

  # Logging.
  cluster_enabled_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  #  dataplane_wait_duration = "30s"
}

resource "null_resource" "wait_for_eks_cluster" {
  depends_on = [module.eks]

  triggers = {
    cluster_name = module.eks.cluster_name
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e
      echo "Waiting for the EKS cluster to be ready..."
      aws eks wait cluster-active --name ${module.eks.cluster_name} --region=${var.region}
    EOT
  }
}

resource "null_resource" "kubeconfig" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      set -e
      echo 'Adding ./kube/config context for the Amazon EKS cluster...'
      export KUBECONFIG="~/.kube/config-${var.cluster_name}"
      aws eks wait cluster-active --name ${var.cluster_name} --region=${var.region}
      aws eks update-kubeconfig --name ${var.cluster_name} --alias ${var.cluster_name} --region=${var.region} --role-arn ${aws_iam_role.cluster_admin.arn} --kubeconfig $KUBECONFIG
    EOT
  }
}

# [2024-02-07] Backward compatibility for previous version of EKS module (< 20.0.0).
module "auth_map" {
  source = "terraform-aws-modules/eks/aws//modules/aws-auth"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = aws_iam_role.cluster_admin.arn
      username = aws_iam_role.cluster_admin.name
      groups   = ["system:masters"]
    },
    {
      rolearn = aws_iam_role.cluster_deploy.arn
      username = aws_iam_role.cluster_deploy.name
      groups = ["system:masters"]
    }
  ]

  depends_on = [null_resource.wait_for_eks_cluster]
}

/**
 * Certificate issued by private CA for various ALBs.
 */
module "aws_acm_certificate" {
  source = "./aws-acm-certificate"
  certificate_authority_arn = var.certificate_authority_arn
  eks_cluster_name = var.cluster_name
}

# [2024-02-12] Add-on and miscellaneous resources are consolidated into a single module.
# This it to avoid slow dependency resolution and to make the code more readable.
module "eks_addons" {
  source = "./eks-addons"

  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_cluster_name = module.eks.cluster_name
  oidc_provider = module.eks.oidc_provider
  oidc_provider_arn = module.eks.oidc_provider_arn
  region = var.region
  aws_acm_certificate_arn = module.aws_acm_certificate.certificate_arn
  grafana_admin_password = var.grafana_admin_password
  create_karpenter = var.create_karpenter

  defectdojo_admin_password = var.defectdojo_admin_password

  additional_iam_policy_arns = var.additional_iam_policy_arns

  depends_on = [null_resource.wait_for_eks_cluster]
}

###
### Karpenter.
###
locals {
  karpenter_service_account_name = "karpenter-controller-service-account"
}

# Refer to: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter
# (주의) Karpenter 모듈에서 "depends_on" 메타 파라미터를 사용하면 "new karpenter policy attachment fails" 에러가 발생합니다.
# 또한 현재의 버전으로 마이그레이션 하는 방법에 대한 내용은 아래 링크를 참조하세요.
# Refer to: https://marcincuber.medium.com/amazon-eks-migrating-karpenter-resources-from-alpha-to-beta-api-version-7bf320bbecb5
# (Disclaimer) 테스트되지 않았습니다.
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name
  enable_irsa = true
  enable_pod_identity = true
  irsa_namespace_service_accounts = ["karpenter:${local.karpenter_service_account_name}"]
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  iam_role_use_name_prefix = true
  create_node_iam_role = true
  node_iam_role_use_name_prefix = false

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  }
}

# Karpenter controller
# Refer to: https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/
resource "helm_release" "karpenter" {
  # (참고) karpenter v0.34.0 버전에서는 karpenter-controller-manager가 아닌 karpenter-controller로 변경되었습니다.
  # (주의) 만약 "not found" 메시지가 나오면 "helm registry logout public.ecr.aws" 명령어를 실행하고 다시 실행해보세요.
  # https://karpenter.sh/preview/troubleshooting/#helm-error-when-pulling-the-chart
  # https://gallery.ecr.aws/karpenter/karpenter
  repository = "oci://public.ecr.aws/karpenter"
  chart = "karpenter"
  version = "v0.34.0"
  name  = "karpenter"
  namespace = "karpenter"
  create_namespace = true

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name = "settings.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name = "serviceAccount.create"
    value = true
  }

  set {
    name = "serviceAccount.name"
    value = local.karpenter_service_account_name
  }

  set {
    name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    # Renamed: irsa_arn -> iam_role_arn
    # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/UPGRADE-20.0.md
    value = module.karpenter.iam_role_arn
  }

  #  set {
  #    name = "settings.aws.defaultInstanceProfile"
  #    value = module.karpenter.instance_profile_name
  #  }

  set {
    name = "settings.interruptionQueue"
    value = module.karpenter.queue_name
  }

  timeout = 1200

  #  depends_on = [module.karpenter, module.karpenter.queue_arn]
  depends_on = [module.karpenter.queue_arn]
}

# Following resources have template file upgrded with "karpenter_converter" tool.
# Refer to: https://github.com/aws/karpenter-provider-aws/tree/release-v0.32.6/tools/karpenter-convert
# go install github.com/aws/karpenter/tools/karpenter-convert/cmd/karpenter-convert@release-v0.32.x
resource "kubectl_manifest" "nodeclass" {
  for_each  = data.kubectl_path_documents.nodeclass_manifests.manifests
  yaml_body = each.value
  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "nodepool" {
  for_each  = data.kubectl_path_documents.nodepool_manifests.manifests
  yaml_body = each.value
  depends_on = [helm_release.karpenter]
}
