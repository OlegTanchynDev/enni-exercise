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
