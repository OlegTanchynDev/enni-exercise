# The skip_* flags + dummy static creds let `terraform validate` and
# `terraform plan` run completely offline — no AWS account, no network calls,
# no real credentials. This is deliberate: the grader runs
# `terraform init -backend=false` then `terraform validate` (and optionally
# `terraform plan`) to assess the candidate's change without anyone ever
# touching real infrastructure. Nothing here is ever applied.
provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}
