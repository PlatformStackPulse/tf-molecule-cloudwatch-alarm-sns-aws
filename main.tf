# -----------------------------------------------------
# Molecule: CloudWatch Alarm + SNS
# Composes a metric alarm with an SNS topic and optional
# email/Lambda subscriptions for alerting.
# -----------------------------------------------------

# --- SNS Topic for alarm notifications ---
module "topic" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-sns-topic-aws.git?ref=69c0da3e590cb2771ed79fede69948b2b83b6cfa"

  context           = module.this.context
  kms_master_key_id = var.sns_kms_key_id
}

# --- SNS Subscriptions ---
module "subscriptions" {
  source   = "git::https://github.com/PlatformStackPulse/tf-atom-sns-topic-subscription-aws.git?ref=7a83cfcf5c70e8826cda3c1dd6e97ce1c7bc4c63"
  for_each = { for idx, sub in var.subscriptions : idx => sub }

  context   = module.this.context
  topic_arn = module.topic.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint

  depends_on = [module.topic]
}

# --- CloudWatch Metric Alarm ---
module "alarm" {
  source = "git::https://github.com/PlatformStackPulse/tf-atom-cloudwatch-metric-alarm-aws.git?ref=99d397f88e216658b461263a751dd12fcc97ef5c"

  context             = module.this.context
  alarm_description   = var.alarm_description
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_periods
  metric_name         = var.metric_name
  metric_namespace    = var.metric_namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold
  treat_missing_data  = var.treat_missing_data
  dimensions          = var.dimensions

  alarm_actions             = [module.topic.arn]
  ok_actions                = var.notify_on_ok ? [module.topic.arn] : []
  insufficient_data_actions = []

  depends_on = [module.topic]
}
