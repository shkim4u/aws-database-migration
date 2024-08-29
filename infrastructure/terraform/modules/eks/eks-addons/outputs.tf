output "aws_load_balancer_controller" {
  value = module.aws_load_balancer_controller
}

output "aws_load_balancer_controller_id" {
  value = module.aws_load_balancer_controller.id
}

output "aws_ebs_csi_driver" {
  value = module.aws_ebs_csi_driver
}

output "aws_ebs_csi_driver_id" {
  value = module.aws_ebs_csi_driver.ebs_csi_driver_id
}
