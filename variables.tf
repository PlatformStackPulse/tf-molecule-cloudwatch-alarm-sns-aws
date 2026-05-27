# -----------------------------------------------------------------------------
# Module-Specific Variables
# -----------------------------------------------------------------------------

# --- Alarm ---
variable "alarm_description" {
  description = "Description of the alarm"
  type        = string
  default     = null
}

variable "comparison_operator" {
  description = "Comparison operator (GreaterThanThreshold, LessThanThreshold, etc.)"
  type        = string
  default     = "GreaterThanThreshold"
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate"
  type        = number
  default     = 1
}

variable "metric_name" {
  description = "Name of the CloudWatch metric"
  type        = string
}

variable "metric_namespace" {
  description = "Namespace of the metric (e.g., AWS/Lambda, AWS/EC2)"
  type        = string
}

variable "period" {
  description = "Period in seconds"
  type        = number
  default     = 300
}

variable "statistic" {
  description = "Statistic (Average, Sum, Maximum, Minimum, SampleCount)"
  type        = string
  default     = "Sum"
}

variable "threshold" {
  description = "Threshold value that triggers the alarm"
  type        = number
}

variable "treat_missing_data" {
  description = "How to treat missing data (missing, ignore, breaching, notBreaching)"
  type        = string
  default     = "missing"
}

variable "dimensions" {
  description = "Map of dimensions for the metric"
  type        = map(string)
  default     = {}
}

variable "notify_on_ok" {
  description = "Whether to send notification when alarm returns to OK"
  type        = bool
  default     = true
}

# --- SNS ---
variable "sns_kms_key_id" {
  description = "KMS key ID for SNS topic encryption"
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "List of subscriptions to create on the SNS topic"
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}
