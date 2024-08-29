# Define the Transit Gateway data source
data "aws_ec2_transit_gateway" "dms_tgw" {
  filter {
    name   = "tag:Name"
    values = [var.dms_tgw_name]
  }
}
