###
### EKS Cluster Add-ons 리소스
### (참고) 여기에 정의된 리소스는 EKS 클러스터 생성 후에 생성되어야 함.
### 그리고 여기에 사용된 "Add-on" 이라는 용어는 AWS EKS가 공식적으로 제공하는 Add-on과는 무관함.
### 생성되는 리소스는 다음과 같음:
### - AWS Load Balancer Controller
### - Cert Manager
### - Karpenter
### - Metrics Server
### - AWS EBS CSI Driver
### - AWS EFS CSI Driver
### - VPC CNI Metrics Helper
### - Kubernetes Dashboard
### - Istio
### - Prometheus
### - Grafana
### - Kiali
### - ACK (AWS Controller for Kubernetes)
### - Kubehelper
### - Riches
### - FlightSpecials
### - DefectDojo
### - SecureCodeBox
### - ArgoCD
### - Argo Rollouts
### - Game2048
### - AWSCLI
### - CronJob AWSCLI
###

# AWS CLI를 사용하여 EKS 클러스터가 생성되었는지 확인하는 리소스.
# 세부 설명: Terraform Provider 레벨에서 이를 지원하는 기능이 없어서, null_resource를 사용하여 AWS CLI를 사용하여 EKS 클러스터가 생성되었는지 확인하는 리소스를 생성함.
# 참고: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/943
resource "null_resource" "wait_for_cluster" {
  triggers = {
    cluster_certificate_authority_data = var.cluster_certificate_authority_data
  }

  provisioner "local-exec" {
    command = <<EOT
      set -e

      cluster_name="${var.eks_cluster_name}"
      region="${var.region}"

      while true; do
        nodegroup=$(aws eks list-nodegroups --cluster-name $cluster_name --region $region --query "nodegroups[0]" --output text)

        if [[ $nodegroup != "None" ]]; then
          echo "Cluster has at least 1 node group: $nodegroup"
          break
        else
          echo "Waiting for cluster to have at least 1 node group..."
          sleep 10
        fi
      done

      echo "Waiting for the EKS cluster and its nodegroup to be ready..."
      aws eks wait nodegroup-active --cluster-name $cluster_name --nodegroup-name $nodegroup --region=$region
      aws eks wait cluster-active --name $cluster_name --region=$region
    EOT
  }
}

/**
 * Certificate manager.
 * (Not)
 * A resource created by terraform after its creation comsumes CPU/RAM on cluster where it is created,
 * so some kind of delay is needed before the next resource on the same cluster is created.
 * As an option to achieve this it was decided to use time_sleep terraform resource to implement some delay
 * before resources creation.
 * Refer: https://discuss.hashicorp.com/t/terraform-how-to-properly-implement-delay-with-for-each-and-time-sleep-resource/32514
 */
module "cert_manager" {
  source = "./cert-manager"
  depends_on = [null_resource.wait_for_cluster]
}

/**
 * AWS load balancer controller.
 * Alt 2: Set up AWS load balancer controller from scratch.
 */
module "aws_load_balancer_controller" {
  source = "./aws-load-balancer-controller-greenfield"

  cluster_name = var.eks_cluster_name
  cluster_identity_oidc_issuer = var.oidc_provider
  cluster_identity_oidc_issuer_arn = var.oidc_provider_arn
  aws_region = var.region

  depends_on = [module.cert_manager]
}

/**
 * AWS EBS CSI driver for Prometheus.
 */
module "aws_ebs_csi_driver" {
  source = "./aws-ebs-csi-driver"
  irsa_oidc_provider_arn = var.oidc_provider_arn

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * AWS EFS CIS driver for others especially in need for cross-zone access.
 */
module "aws_efs_csi_driver" {
  source = "./aws-efs-csi-driver"
  irsa_oidc_provider_arn = var.oidc_provider_arn

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * VPC CNI Metrics Helper
 */
module "vpc_cni_metrics_helper" {
  source = "./vpc-cni-metrics-helper"
  cluster_name = var.eks_cluster_name
  irsa_oidc_provider_arn = var.oidc_provider_arn

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * Metrics server
 */
module "metrics_server" {
  source = "./metrics-server"

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * Install Kubernetes Dashboard with Helm.
 * - https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard
 *
 * How to connect
 * - https://archive.eksworkshop.com/beginner/040_dashboard/
 * - https://github.com/kubernetes/dashboard/blob/master/charts/helm-chart/kubernetes-dashboard/templates/networking/ingress.yaml
 *
 * (참고)
 * 위의 Ingress Yaml 파일을 보면 Nginx만 Ingress 자원으로 정의하고 있음 -> AWS ALB 미지원!
 * (필독) https://github.com/kubernetes/dashboard/blob/master/docs/common/arguments.md
 *
 * (참고) Kubernetes Dashboard는 다음 경우에만 원격 로그인을 허용 (https://github.com/kubernetes/dashboard/blob/master/docs/user/accessing-dashboard/README.md#login-not-available)
 * - http://localhost/...
 * - http://127.0.0.1/...
 * - https://<domain_name>/...
 *
 * * 설정 후 로그인 방법: https://archive.eksworkshop.com/beginner/040_dashboard/connect/
 * 1. Kubeconfig가 설정된, 혹은 EKS에 접속 가능한 AWS Principal이 설정된 환경에서
 * 2. aws eks get-token --cluster-name M2M-EksCluster --role arn:aws:iam::805178225346:role/M2M-EksCluster-ap-northeast-2-MasterRole | jq -r '.status.token'
 * 3. 위 2의 결과를 로그인 창에 복사 후 로그인
 *
 */
module "kubernetes_dashboard" {
  source = "./kubernetes-dashboard"
  certificate_arn = var.aws_acm_certificate_arn

  depends_on = [module.aws_load_balancer_controller]
}

/**
 * Istio.
 */
module "istio" {
  source = "./istio"

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * Prometheus.
 */
module "prometheus" {
  source = "./prometheus"
  depends_on = [module.metrics_server, module.aws_ebs_csi_driver, module.aws_load_balancer_controller]
}

/**
 * Grafana.
 */
module "grafana" {
  source = "./grafana"
  certificate_arn = var.aws_acm_certificate_arn
  admin_password = var.grafana_admin_password
  depends_on = [module.prometheus]
}

/**
 * Kiali.
 */
module "kiali" {
  source = "./kiali"
  depends_on = [module.istio, module.prometheus]
}

/**
 * ACK (AWS Controller for Kubernetes)
 */
module "ack" {
  source = "./ack"
  irsa_oidc_provider_arn = var.oidc_provider_arn
  eks_cluster_name = var.eks_cluster_name

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * Kubehelper
 */
module "kubehelper" {
  source = "./kubehelper"

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * [2023-08-11]
 * More to come
 */
#1. ADOT
#2. GuardDuty Agent
#3. Kubecost: 비용 통제
#$ helm repo add kubecost https://kubecost.github.io/cost-analyzer/
#$ helm upgrade --install kubecost kubecost/cost-analyzer --namespace kubecost --create-namespace
#4. Kpow: 카프카 관리 (MSK)
#5. Teleport: 접근 제어
#6. Tetrate: Application-aware networking
#1. https://academy.tetrate.io/
#7. Datree: Manifest 검증
#8. Kasten: 백업 및 복구 (cf. Velero)


###
### [2024-02-03] ASPM (Application Security Posture Management) with Django-Defectdojo
### Centralize to production cluster.
### (참고) Staging 클러스터에서 DAST 스캔을 구성할 시 ZAP 스캐너의 Persistence Hook의 Target URL을 Production 클러스터에
### 설치된 DefctDojo의 Internal ALB를 가리키도록 설정할 것을 권장.
###
# module "defectdojo" {
#   source = "./defectdojo"
#   eks_cluster_name = var.eks_cluster_name
#
#   admin_password = var.defectdojo_admin_password
#   certificate_arn = var.aws_acm_certificate_arn
#
#   depends_on = [null_resource.wait_for_cluster, module.aws_ebs_csi_driver, module.aws_load_balancer_controller]
# }

/*
 * SecureCodeBox for DAST (Dynamic Application Security Testing)
 */
# module "securecodebox" {
#   source = "./securecodebox"
#   eks_cluster_name = var.eks_cluster_name
#
#   defectdojo_admin_password = var.defectdojo_admin_password
#
#   depends_on = [null_resource.wait_for_cluster, module.defectdojo]
# }


/**
 * ArgoCD.
 */
module "argocd" {
  source = "./argocd"
  certificate_arn = var.aws_acm_certificate_arn

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * Argo Rollouts.
 */
module "argo_rollouts" {
  source = "./argo-rollouts"

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * Geme2048 for fun using Istio.
 */
module "game2048" {
  source = "./game2048"
  certificate_arn = var.aws_acm_certificate_arn

  # This module had better to get deployed after Istio is deployed, as its pod will be injected with Istio sidecar.
  depends_on = [null_resource.wait_for_cluster, module.istio, module.aws_load_balancer_controller]
}

/**
 * AWSCLI pod for fun.
 */
module "awscli" {
  source = "./awscli"
  irsa_oidc_provider_arn = var.oidc_provider_arn
  eks_cluster_name = var.eks_cluster_name

  depends_on = [null_resource.wait_for_cluster]
}

module "cronjob_awscli" {
  source = "./cronjob-awscli"
  irsa_oidc_provider_arn = var.oidc_provider_arn
  eks_cluster_name = var.eks_cluster_name

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * Miscellaneous resources for general hands-on purpose.
 */
module "hands-on" {
  source = "./hands-on"
  eks_cluster_name = var.eks_cluster_name
  irsa_oidc_provider_arn = var.oidc_provider_arn
  additional_iam_policy_arns = var.additional_iam_policy_arns
  certificate_arn = var.aws_acm_certificate_arn
  depends_on = [null_resource.wait_for_cluster]
}

/**
 * Network testing.
 * - Network multitool
 * - tcpdump, ip, route etc.
 */
module "network-testing" {
  source = "./network-testing"
  depends_on = [null_resource.wait_for_cluster]
  certificate_arn = var.aws_acm_certificate_arn
}

/**
 * TravelBuddy - HotelSpecials.
 */
module "hotelspecials" {
  source = "./hotelspecials"
  eks_cluster_name = var.eks_cluster_name
  irsa_oidc_provider_arn = var.oidc_provider_arn

  depends_on = [null_resource.wait_for_cluster]
}

/**
 * TravelBuddy - FlightSpecials.
 */
module "flightspecials" {
  source                 = "./flightspecials"
  eks_cluster_name = var.eks_cluster_name
  irsa_oidc_provider_arn = var.oidc_provider_arn

  depends_on = [null_resource.wait_for_cluster]
}
