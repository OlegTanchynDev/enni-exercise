# frozen_string_literal: true

source "https://rubygems.org"

# ── Core ────────────────────────────────────────────────────────────────────
gem "bootsnap", require: false
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "rails", "~> 7.2.3", ">= 7.2.3.1"
gem "sprockets-rails"
gem "tzinfo-data", platforms: %i[windows jruby]

# ── Frontend (importmap + Hotwire; Bootstrap 5 via CDN, no Node build) ───────
gem "haml-rails", "~> 2.0"
gem "importmap-rails"
gem "stimulus-rails"
gem "turbo-rails"

# ── Auth / authorization ────────────────────────────────────────────────────
gem "devise", "~> 4.9"            # web session auth
gem "doorkeeper", "~> 5.8"        # OAuth2 for the API
gem "pundit", "~> 2.4"            # authorization policies

# ── Domain support ──────────────────────────────────────────────────────────
gem "aasm", "~> 5.5"             # state machines
gem "audited", "~> 5.8"          # audit trail
gem "shrine", "~> 3.6"           # file uploads (filesystem in dev, S3 in prod)

# ── Background jobs ─────────────────────────────────────────────────────────
# connection_pool 3.x changed TimedStack#pop to keyword-only, which crashes the
# Sidekiq 7.3 scheduler thread at boot (retries + scheduled jobs die silently).
gem "connection_pool", "< 3"
gem "redis", "~> 5.3"
gem "sidekiq", "~> 7.3"

# ── External AI provider (HTTP) ─────────────────────────────────────────────
gem "httparty", "~> 0.22" # real provider uses this; the stub mimics its shape

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.4"
  gem "n_plus_one_control", "~> 0.7" # assert query counts in specs (the N+1 fix becomes provable)
  gem "rspec-rails", "~> 7.1"
  gem "shoulda-matchers", "~> 8.0"
  gem "test-prof", "~> 1.4" # let_it_be / before_all

  # Quality / security gates (also run in CI).
  gem "brakeman", require: false
  gem "haml_lint", require: false
  gem "rubocop", "~> 1.69", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "simplecov", require: false
end
