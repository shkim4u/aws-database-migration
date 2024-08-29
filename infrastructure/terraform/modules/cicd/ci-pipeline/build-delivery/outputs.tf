output "build_artifact_bucket_arn" {
  value = aws_s3_bucket.build.arn
}

output "codebuild_project_id" {
  value = aws_codebuild_project.build.id
}
