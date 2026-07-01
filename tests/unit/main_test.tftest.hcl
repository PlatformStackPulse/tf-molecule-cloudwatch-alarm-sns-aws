# Unit Tests — tf-molecule-cloudwatch-alarm-sns-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# Assertions target plan-KNOWN values only (tf-label id, enabled flag,
# subscription fan-out counts). Computed arn/id values are unknown under a
# mock provider and are therefore only asserted for null in the disabled case.
#
# Run:         terraform test -test-directory=tests/unit
# Verbose:     terraform test -test-directory=tests/unit -verbose

mock_provider "aws" {}

variables {
  # tf-label identity
  namespace = "eg"
  stage     = "test"
  name      = "thing"

  # Required module inputs (no defaults)
  metric_name      = "Errors"
  metric_namespace = "AWS/Lambda"
  threshold        = 5

  # Optional inputs exercised for fan-out coverage
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 300
  statistic           = "Sum"
  subscriptions = [
    { protocol = "email", endpoint = "ops@example.com" },
  ]
}

# ---------------------------------------------------------------------------
# When enabled, the module composes the alarm + topic and derives a
# tf-label id from namespace/stage/name.
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = output.enabled == true
    error_message = "Module should report enabled == true by default."
  }

  assert {
    condition     = module.this.id == "eg-test-thing"
    error_message = "tf-label id should be 'eg-test-thing' from namespace/stage/name."
  }

  assert {
    condition     = length(module.subscriptions) == 1
    error_message = "Exactly one SNS subscription should be planned for the single subscription input."
  }
}

# ---------------------------------------------------------------------------
# When disabled, the count-gated atoms create nothing, so arn outputs
# resolve to null (plan-known via try(...[0], null)).
# ---------------------------------------------------------------------------
run "disabled_creates_nothing" {
  command = plan

  variables {
    enabled = false
    # No subscriptions: with the topic disabled its arn is null, and the
    # subscription atom rejects a null/empty topic_arn. Disabled means nothing
    # to subscribe to.
    subscriptions = []
  }

  assert {
    condition     = output.enabled == false
    error_message = "Module should report enabled == false when disabled."
  }

  assert {
    condition     = output.alarm_arn == null
    error_message = "No CloudWatch alarm should be created when disabled (alarm_arn must be null)."
  }

  assert {
    condition     = output.topic_arn == null
    error_message = "No SNS topic should be created when disabled (topic_arn must be null)."
  }
}
