provider "aws" {
  region = var.region
  default_tags {
    tags = {
      "Managed_By" = "Terraform"
      "Purpose" = "Amazon-Database-Migration-Workshop-By-ProServe"
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
