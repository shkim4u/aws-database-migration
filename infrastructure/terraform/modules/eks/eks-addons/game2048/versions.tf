terraform {
  required_version = ">= 1.0"

  required_providers {
    // https://github.com/gavinbunney/terraform-provider-kubectl
    kubectl = {
#      source  = "gavinbunney/kubectl"
#      version = ">= 1.14"
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}
