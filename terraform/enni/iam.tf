# IAM policy granting the ECS task role access to the uploads bucket.
#
# TASK 4c. This s3:* grant is over-broad (and mirrors a real smell in the prod
# codebase). Tighten it to least privilege for what Shrine actually does — list,
# and read/write/delete objects. No action wildcards. See TASK.md.
resource "aws_iam_policy" "task_s3_access" {
  name        = "enni-${var.environment}-task-s3-access"
  description = "Cleaning-verification task access to the uploads bucket (NEEDS SCOPING)."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Fixme"
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          aws_s3_bucket.uploads.arn,
          "${aws_s3_bucket.uploads.arn}/*",
        ]
      },
    ]
  })

  tags = local.common_tags
}
