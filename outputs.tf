output "enabled" {
  description = "Whether the module is enabled"
  value       = local.enabled
}

output "alarm_arn" {
  description = "ARN of the CloudWatch alarm"
  value       = module.alarm.arn
}

output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.topic.arn
}

output "topic_name" {
  description = "Name of the SNS topic"
  value       = module.topic.name
}
