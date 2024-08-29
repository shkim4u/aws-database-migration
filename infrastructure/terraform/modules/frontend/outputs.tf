output "frontend_cloudfront_domain_name" {
  value = aws_cloudfront_distribution.travelbuddy_frontend.domain_name
}
