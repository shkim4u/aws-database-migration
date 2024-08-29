module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  /*
   * Basic information
   */
  name = "M2M-VPC"
  cidr = "10.21.0.0/16"
  azs = var.azs

  /*
   * Subnets
   */
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb": 1,
    "karpenter.sh/discovery/M2M-EksCluster": 1
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb": 1,
  }

  /*
   * Misc.
   */
  enable_nat_gateway = true
  single_nat_gateway = false
  enable_dns_support = true
  enable_dns_hostnames = true

  map_public_ip_on_launch = true
}
