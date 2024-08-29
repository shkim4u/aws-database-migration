output "post_process_artifact_bucket_arn" {
    value = aws_s3_bucket.post_process.arn
}

output "codebuild_project_id" {
  value = aws_codebuild_project.post_process.id
}
