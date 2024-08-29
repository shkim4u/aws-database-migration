output "ca_arn" {
  value = var.certificate_authority_arn
}

output "certificate_arn" {
  value = aws_acm_certificate.this.arn
}
