output "vpc_id" {
  description = "VPC ID"
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR Block"
  value = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "List of public subnets"
  value = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "Public Subnets CIDR Block"
  value = module.vpc.public_subnets_cidr_blocks
}

output "private_subnets" {
  description = "List of private subnets"
  value = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "Private Subnets CIDR Block"
  value = module.vpc.private_subnets_cidr_blocks
}

output "nat_gateway_id_0" {
    description = "NAT Gateway ID 0"
    value = module.vpc.natgw_ids[0]
}

output "nat_gateway_id_1" {
  description = "NAT Gateway ID 0"
  value = module.vpc.natgw_ids[1]
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value = module.vpc.natgw_ids
}

# Output the Transit Gateway Attachment ID
output "transit_gateway_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.dms_tgw_vpc_attachment.id
}
