# Severity-tiered SNS topics. In production these fan out to Slack via the
# terraform-aws-modules/notify-slack module; in this skeleton they are plain
# SNS topics so the module validates and plans with zero external downloads.
# An alarm picks its audience by publishing to the matching topic ARN:
#
#   pages  → sev-1, wake someone now      (e.g. API 5xx storm, RDS CPU > 90%)
#   alerts → sev-2, investigate this hour (e.g. elevated error/failure rate)
#   info   → sev-3, muted digest          (e.g. deploy + daily summary)

resource "aws_sns_topic" "pages" {
  name = "enni-${var.environment}-pages"
  tags = local.common_tags
}

resource "aws_sns_topic" "alerts" {
  name = "enni-${var.environment}-alerts"
  tags = local.common_tags
}

resource "aws_sns_topic" "info" {
  name = "enni-${var.environment}-info"
  tags = local.common_tags
}
