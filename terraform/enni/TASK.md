# Pillar 4 — Infrastructure (Terraform / AWS)

This module is a slimmed, self-contained version of the real `enni-infrastructure`
repo. It is graded **entirely offline** — nobody applies it. You do not need an
AWS account, credentials, or network access beyond the one-time provider
download.

## How to work on it

```bash
cd terraform/enni
terraform init -backend=false     # downloads the AWS provider once
terraform validate                # must pass
terraform plan                    # optional; runs offline (dummy creds, skip_* flags)
terraform fmt -check              # keep it formatted
```

## What to do

Three changes, all marked with `TASK 4a/4b/4c` comments in the `.tf` files:

1. **`alarms.tf` (4a)** — Add a CloudWatch alarm for the classification failure
   rate on the custom metric `Enni/Classification → FailedClassifications`,
   routed to the correct severity SNS topic. **Justify your threshold, period,
   and severity in a comment.** We are reading your operational judgement, not
   checking a specific number.

2. **`s3_uploads.tf` (4b)** — Add an `aws_s3_bucket_lifecycle_configuration`
   that expires cleaning photos 90 days after creation.

3. **`iam.tf` (4c)** — Tighten the deliberately over-broad `s3:*` policy to
   least privilege (`s3:ListBucket` on the bucket; `s3:GetObject`,
   `s3:PutObject`, `s3:DeleteObject` on the objects). No action wildcards.

## What we're looking for

- It validates and plans cleanly, and is `terraform fmt`-clean.
- Your alarm threshold is **justified**, not guessed — the way the example
  `rds_connections_high` alarm justifies its 150 from an observed baseline.
- Least privilege is real least privilege (no `s3:*`, no `Resource = "*"`).
- Comments explain *why*, not *what*. This is infrastructure you would own
  alone — write it for the person who reads it at 3am during an incident.
