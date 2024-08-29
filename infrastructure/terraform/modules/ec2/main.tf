resource "aws_security_group" "rds_bastion" {
  vpc_id = var.vpc_id
  name = "RDS-Bastion-SecurityGroup"
  description = "Security group for a RDS bastion host"
}

resource "aws_security_group_rule" "rds_bastion_egress" {
  type = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.rds_bastion.id}"
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "RDS-Bastion"
  subnet_id = var.subnet_id
  iam_role_name = var.role_name
  iam_instance_profile = var.instance_profile_name
#  create_iam_instance_profile = true
  vpc_security_group_ids = ["${aws_security_group.rds_bastion.id}"]
  instance_type = "m5.4xlarge"
  ami = data.aws_ami.amazon-linux-2.id
  tags = {
    "Patch Group" = "AccountGuardian-PatchGroup-DO-NOT-DELETE"
  }
}
