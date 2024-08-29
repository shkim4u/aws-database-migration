provider "aws" {
  region = var.region
  default_tags {
    tags = {
      "Managed_By" = "Terraform"
      "Purpose" = "Amazon-EKS-Extended-Workshop-By-ProServe"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
