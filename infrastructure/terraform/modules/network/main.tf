module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  /*
   * Basic information
   */
  name = "M2M-VPC"
  cidr = var.vpc_cidr
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

# Create the Transit Gateway Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "dms_tgw_vpc_attachment" {
#   subnet_ids         = aws_subnet.public[*].id
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = data.aws_ec2_transit_gateway.dms_tgw.id
  vpc_id             = module.vpc.vpc_id

  tags = {
    Name = "DMS-TGW-Workload-VPC-Attachment"
  }
}

# TODO: Fix this.
# # Add a route to the public subnets' route tables
# resource "aws_route" "dms_tgw_public_subnet_route" {
#   count                  = length(module.vpc.public_subnets)
#   route_table_id         = element(module.vpc.public_subnets, count.index).route_table_id
#   destination_cidr_block = var.dms_tgw_route
#   transit_gateway_id     = data.aws_ec2_transit_gateway.dms_tgw.id
# }
#
# # Add a route to the private subnets' route tables
# resource "aws_route" "dms_tgw_private_subnet_route" {
#   count                  = length(module.vpc.private_subnets)
#   route_table_id         = element(module.vpc.private_subnets, count.index).route_table_id
#   destination_cidr_block = var.dms_tgw_route
#   transit_gateway_id     = data.aws_ec2_transit_gateway.dms_tgw.id
# }
