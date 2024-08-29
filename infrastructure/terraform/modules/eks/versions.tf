terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }

    // https://github.com/gavinbunney/terraform-provider-kubectl
    kubectl = {
#      source  = "gavinbunney/kubectl"
#      version = ">= 1.14"

      # Related issues:
      # - https://github.com/gavinbunney/terraform-provider-kubectl/issues/270
      # - https://www.tinfoilcipher.co.uk/2020/10/26/terraform-and-kubernetes-working-with-multiple-clusters/
      # - https://honglab.tistory.com/233
      # For existing cluster,
      # terraform state replace-provider registry.terraform.io/gavinbunney/kubectl registry.terraform.io/alekc/kubectl
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}
