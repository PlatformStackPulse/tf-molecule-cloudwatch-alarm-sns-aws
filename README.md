# tf-molecule-cloudwatch-alarm-sns-aws

Terraform molecule that composes a CloudWatch metric alarm with an SNS topic and subscriptions for alerting.

## Features

- **Metric alarm + notification in one module** — wires a `aws_cloudwatch_metric_alarm` to a dedicated SNS topic so alarm state changes fan out to subscribers automatically.
- **Configurable alarm semantics** — comparison operator, evaluation periods, period, statistic, threshold, dimensions, and `treat_missing_data` are all exposed as inputs.
- **OK-state notifications** — `notify_on_ok` (default `true`) also routes the alarm's return-to-OK transition through the same SNS topic.
- **Flexible subscriptions** — a `subscriptions` list creates any mix of `email`, `lambda`, `sqs`, `https`, etc. endpoints on the topic.
- **Optional SNS encryption** — `sns_kms_key_id` enables server-side encryption for the topic at rest.
- **tf-label context chaining** — inherits the standard `namespace`/`stage`/`name`/`environment` labelling and `enabled` toggle from `tf-label`; setting `enabled = false` creates no resources.

## Atoms Composed

| Atom | Purpose |
|------|---------|
| `tf-atom-cloudwatch-metric-alarm-aws` | Creates the metric alarm |
| `tf-atom-sns-topic-aws` | Creates the notification topic |
| `tf-atom-sns-topic-subscription-aws` | Creates subscriptions (email, Lambda, SQS, etc.) |

## Usage

```hcl
module "lambda_errors_alarm" {
  source = "git::https://github.com/PlatformStackPulse/tf-molecule-cloudwatch-alarm-sns-aws.git?ref=v1.0.0"

  namespace   = "psp"
  environment = "prod"
  name        = "lambda-errors"

  metric_name      = "Errors"
  metric_namespace = "AWS/Lambda"
  threshold        = 5
  dimensions       = { FunctionName = "my-function" }

  subscriptions = [
    { protocol = "email", endpoint = "ops@example.com" },
    { protocol = "lambda", endpoint = "arn:aws:lambda:eu-west-2:123:function:alerter" }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

### Providers

No providers.

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alarm"></a> [alarm](#module\_alarm) | git::https://github.com/PlatformStackPulse/tf-atom-cloudwatch-metric-alarm-aws.git | 99d397f88e216658b461263a751dd12fcc97ef5c |
| <a name="module_subscriptions"></a> [subscriptions](#module\_subscriptions) | git::https://github.com/PlatformStackPulse/tf-atom-sns-topic-subscription-aws.git | 7a83cfcf5c70e8826cda3c1dd6e97ce1c7bc4c63 |
| <a name="module_this"></a> [this](#module\_this) | git::https://github.com/PlatformStackPulse/tf-label.git | v1.0.0 |
| <a name="module_topic"></a> [topic](#module\_topic) | git::https://github.com/PlatformStackPulse/tf-atom-sns-topic-aws.git | 69c0da3e590cb2771ed79fede69948b2b83b6cfa |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | Name of the CloudWatch metric | `string` | n/a | yes |
| <a name="input_metric_namespace"></a> [metric\_namespace](#input\_metric\_namespace) | Namespace of the metric (e.g., AWS/Lambda, AWS/EC2) | `string` | n/a | yes |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | Threshold value that triggers the alarm | `number` | n/a | yes |
| <a name="input_alarm_description"></a> [alarm\_description](#input\_alarm\_description) | Description of the alarm | `string` | `null` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator) | Comparison operator (GreaterThanThreshold, LessThanThreshold, etc.) | `string` | `"GreaterThanThreshold"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes and tags, which are merged. | <pre>object({<br/>    enabled             = optional(bool, true)<br/>    namespace           = optional(string, null)<br/>    tenant              = optional(string, null)<br/>    environment         = optional(string, null)<br/>    stage               = optional(string, null)<br/>    name                = optional(string, null)<br/>    delimiter           = optional(string, null)<br/>    attributes          = optional(list(string), [])<br/>    tags                = optional(map(string), {})<br/>    label_order         = optional(list(string), null)<br/>    regex_replace_chars = optional(string, null)<br/>    id_length_limit     = optional(number, null)<br/>    label_key_case      = optional(string, null)<br/>    label_value_case    = optional(string, null)<br/>    labels_as_tags      = optional(set(string), null)<br/>    descriptor_formats = optional(map(object({<br/>      format = string<br/>      labels = list(string)<br/>    })), {})<br/>  })</pre> | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | <pre>map(object({<br/>    format = string<br/>    labels = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | Map of dimensions for the metric | `map(string)` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'. | `string` | `null` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | Number of periods to evaluate | `number` | `1` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` to keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>Note: The value of the `name` tag, if included, will be the `id`, not the `name`. | `set(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique. | `string` | `null` | no |
| <a name="input_notify_on_ok"></a> [notify\_on\_ok](#input\_notify\_on\_ok) | Whether to send notification when alarm returns to OK | `bool` | `true` | no |
| <a name="input_period"></a> [period](#input\_period) | Period in seconds | `number` | `300` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_sns_kms_key_id"></a> [sns\_kms\_key\_id](#input\_sns\_kms\_key\_id) | KMS key ID for SNS topic encryption | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'. | `string` | `null` | no |
| <a name="input_statistic"></a> [statistic](#input\_statistic) | Statistic (Average, Sum, Maximum, Minimum, SampleCount) | `string` | `"Sum"` | no |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | List of subscriptions to create on the SNS topic | <pre>list(object({<br/>    protocol = string<br/>    endpoint = string<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element. A customer identifier, indicating who this instance of a resource is for. | `string` | `null` | no |
| <a name="input_treat_missing_data"></a> [treat\_missing\_data](#input\_treat\_missing\_data) | How to treat missing data (missing, ignore, breaching, notBreaching) | `string` | `"missing"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_arn"></a> [alarm\_arn](#output\_alarm\_arn) | ARN of the CloudWatch alarm |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether the module is enabled |
| <a name="output_topic_arn"></a> [topic\_arn](#output\_topic\_arn) | ARN of the SNS topic |
| <a name="output_topic_name"></a> [topic\_name](#output\_topic\_name) | Name of the SNS topic |
<!-- END_TF_DOCS -->

## Tests

Unit tests use a mock AWS provider (no real AWS calls) and assert on plan-known
values only — the derived `tf-label` id, the `enabled` flag, and subscription
fan-out counts. The disabled path asserts that the count-gated atoms produce
`null` arns.

```bash
# Unit tests (mock provider, plan-only)
terraform test -test-directory=tests/unit

# Integration tests (real provider)
terraform test -test-directory=tests/integration

# Or via the Makefile
make test
```
