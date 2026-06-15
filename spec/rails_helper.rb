# frozen_string_literal: true

require "spec_helper"
# Force test env: the Docker container runs with RAILS_ENV=development, so the
# conventional `||=` would be a no-op and the suite would run against the dev
# database and dev host authorization. `=` guarantees the test environment.
ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "shoulda/matchers"
require "sidekiq/testing"
require "test_prof/recipes/rspec/let_it_be"
require "test_prof/recipes/rspec/before_all"

# Jobs enqueue to an in-memory array (no Redis) in tests. Use
# `Sidekiq::Testing.inline!` inside an example to run them synchronously.
Sidekiq::Testing.fake!

Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join("spec/fixtures")]
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
