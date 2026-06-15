# Every resource in this module is tagged through local.common_tags so cost
# allocation and ownership are queryable in the AWS console. Mirrors the real
# enni-infrastructure tags.tf convention.
locals {
  common_tags = {
    Project     = "enni"
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "cleaning-verification"
  }
}
