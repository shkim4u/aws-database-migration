output "istio_base_id" {
  value = helm_release.istio_base.id
}

output "istio_gateway_name" {
  value = helm_release.istio_gateway.metadata.0.name
}
