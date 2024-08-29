output "rds_bastion_instance_id" {
  description = "ID of RDS bastion"
  value = module.ec2_instance.id
}

output "rds_bastion_public_ip" {
  description = "Public IP of RDS bastion"
  value = module.ec2_instance.public_ip
}

output "rds_bastion_private_ip" {
  description = "Private IP of RDS bastion"
  value = module.ec2_instance.private_ip
}
