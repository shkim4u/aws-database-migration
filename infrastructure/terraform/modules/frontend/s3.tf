resource "aws_s3_bucket" "travelbuddy_frontend" {
  bucket = "travelbuddy-frontend-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

# Buket policy.
data "aws_iam_policy_document" "s3_bucket_policy_document" {
  statement {
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.travelbuddy_frontend.arn}/*"]

    principals {
      type = "AWS"
#      identifiers = [aws_cloudfront_origin_access_identity.travelbuddy_frontend.cloudfront_access_identity_path]
      identifiers = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.travelbuddy_frontend.id}"]
    }
  }
}
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.travelbuddy_frontend.id
  policy = data.aws_iam_policy_document.s3_bucket_policy_document.json
}
