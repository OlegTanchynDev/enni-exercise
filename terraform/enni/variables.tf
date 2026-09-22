variable "region" {
  type        = string
  description = "AWS region. Enni runs in eu-west-2."
  default     = "eu-west-2"
}

variable "environment" {
  type        = string
  description = "Deployment environment (development | staging | production)."
  default     = "staging"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "environment must be one of: development, staging, production."
  }
}

variable "domain_fqdn" {
  type        = string
  description = "Fully-qualified domain for this environment, e.g. staging.enni.space."
  default     = "staging.enni.space"
}
