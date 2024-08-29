output "ci_slack_webhook_url" {
  value = module.ci_pipeline.dev_slack_webhook_url
}

output "ci_slack_channel" {
  value = module.ci_pipeline.dev_slack_channel
}
