output "name" {
  value = helm_release.aws_load_balancer_controller.0.name
}

output "id" {
  value = helm_release.aws_load_balancer_controller.0.id
}
