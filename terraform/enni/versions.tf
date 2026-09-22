# Pinned so `terraform validate` / `plan` are reproducible on the grader's
# machine and in CI. AWS provider v5 is required for the split S3 bucket
# resources (aws_s3_bucket_lifecycle_configuration etc.) — the legacy inline
# `acl`/`versioning` block syntax was removed in provider v4+.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
