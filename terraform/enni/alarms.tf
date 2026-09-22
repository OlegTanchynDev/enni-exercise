# Example alarm to pattern-match. Mirrors the production rds_alarms.tf style:
# an explicit threshold, a comment that JUSTIFIES the number from an observed
# baseline, severity routing via alarm_actions, and an ok_action so recovery is
# announced too.
#
# RDS connection saturation is an independent failure mode from CPU: workers can
# block waiting for a connection slot while CPU stays low, producing 5xx without
# a CPU spike. Observed baseline 20-40, peak ~63; threshold 150 ≈ 2.4x worst peak.
resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "enni-${var.environment}-rds-connections-high"
  alarm_description   = "Aurora connection count > 150 for 5 min (baseline 20-40, peak 63). Possible pool exhaustion or connection leak."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  period              = 60
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  statistic           = "Average"
  threshold           = 150
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = "enni-${var.environment}-shared"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags
}

# TASK 4a. Add an alarm for the classification failure rate. The app publishes
# Enni/Classification -> FailedClassifications (dimension Environment). Route it
# to the right severity topic above and justify your threshold in a comment, like
# the example alarm does. See TASK.md.
#
# A sustained high failure rate in the AI classifier is a critical issue, as it
# directly impacts the core verification workflow. We treat it as high-severity.
# Threshold: >10 failures over 5 minutes. This is a starting point for a new
# system. We expect a near-zero baseline; a sustained rate above 2/min suggests
# a systemic problem (e.g., provider outage, bad deploy, breaking API change)
# that requires immediate attention.
resource "aws_cloudwatch_metric_alarm" "classification_failures_high" {
  alarm_name          = "enni-${var.environment}-classification-failures-high"
  alarm_description   = "AI classification failure rate > 10 for 5 min. Possible provider outage or bad deploy."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  period              = 60 # 1 minute
  metric_name         = "FailedClassifications"
  namespace           = "Enni/Classification"
  statistic           = "Sum"
  threshold           = 10
  treat_missing_data  = "notBreaching"

  dimensions = {
    Environment = var.environment
  }

  # Route to the sev-2 topic for investigation within the hour.
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags
}
