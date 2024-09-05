resource "aws_cloudfront_origin_access_identity" "travelbuddy_frontend" {
  comment = "TravelBuddy Modern Frontend OAI"
}

resource "aws_cloudfront_distribution" "travelbuddy_frontend" {
  comment = "CloudFront distribution for TravelBuddy modern frontend"
  default_root_object = "index.html"
  enabled = true
  http_version = "http2"

  # Origin that CloudFront will connect to.
  origin {
    origin_id = aws_s3_bucket.travelbuddy_frontend.id
    domain_name = aws_s3_bucket.travelbuddy_frontend.bucket_regional_domain_name
    s3_origin_config {
      # Restricting bucket access through an origin access identity (OAI).
      origin_access_identity = aws_cloudfront_origin_access_identity.travelbuddy_frontend.cloudfront_access_identity_path
    }
  }

  # Connect the CDN to the origins.
  default_cache_behavior {
    # Compress resources automatically (gzip).
    compress = true
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    target_origin_id = aws_s3_bucket.travelbuddy_frontend.id

    # Viewer protocol policy.
    # Refer to: https://wellsw.tistory.com/34
    viewer_protocol_policy = "allow-all"
  }

  price_class = "PriceClass_All"

  # 지리적 제한: 특정 국가에서만 접근하도록 화이트리스트 작성
  restrictions {
    geo_restriction {
      restriction_type = "none"
      # locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Product = "TravelBuddy"
  }
}
