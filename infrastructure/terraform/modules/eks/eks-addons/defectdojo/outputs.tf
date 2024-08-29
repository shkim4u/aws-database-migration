#locals {
#  ingress_svc_name      = "defectdojo"
#  ingress_svc_namespace = "defectdojo"
#  ingress_load_balancer_tags = {
#    "elbv2.k8s.aws/cluster"    = var.eks_cluster_name
#    "ingress.k8s.aws/resource" = "LoadBalancer"
#    "ingress.k8s.aws/stack"    = "${local.ingress_svc_namespace}/${local.ingress_svc_name}"
#  }
#}
#
#resource "null_resource" "lb_creation" {
#  triggers = {
#    lb_tags = jsonencode(local.ingress_load_balancer_tags)
#  }
#}
#
#data "aws_lb" "ingress_load_balancer" {
#  depends_on = [null_resource.lb_creation]
#  tags = local.ingress_load_balancer_tags
#}
#
#output "ingress_dns_name" {
#  value = data.aws_lb.ingress_load_balancer.dns_name
#}
