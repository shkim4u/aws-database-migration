output "repository_arn" {
  value = module.ecr.repository_arn
}

output "repository_url" {
  value = module.ecr.repository_url
}

output "repository_name" {
  value = var.name
}
