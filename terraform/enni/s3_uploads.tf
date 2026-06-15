# Cleaning-photo uploads bucket. Shrine writes here in production (MinIO in dev).
# Uses the split aws_s3_bucket_* resources (provider v4+), not the removed
# inline acl/versioning block syntax.
resource "aws_s3_bucket" "uploads" {
  bucket = "uploads.${var.domain_fqdn}"
  tags   = local.common_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# TASK 4b. Cleaning photos are time-limited evidence, not durable assets. Add an
# aws_s3_bucket_lifecycle_configuration that expires them 90 days after creation.
# See TASK.md.
resource "aws_s3_bucket_lifecycle_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    id     = "expire-photos"
    status = "Enabled"

    expiration {
      days = 90
    }

    # This rule applies only to cleaning_photos objects in the bucket.
    filter {
      prefix = "cleaning_photos/"
    }
  }
}

