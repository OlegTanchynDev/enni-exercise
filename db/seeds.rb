# frozen_string_literal: true

# Two operators with isolated data so tenant isolation is demonstrable, plus a
# pre-wired API token. Idempotent: safe to run repeatedly.

VERIFICATION_CYCLE = %w[unverified pending verified flagged].freeze

ActiveRecord::Base.transaction do
  SystemAdmin.find_or_create_by!(email: "admin@enni.test") do |user|
    user.password = "password123"
    user.name = "System Admin"
  end

  [{ name: "Acme Leisure", slug: "acme" }, { name: "Borough Sports", slug: "borough" }].each do |attrs|
    operator = Operator.find_or_create_by!(slug: attrs[:slug]) { |o| o.name = attrs[:name] }

    OperatorUser.find_or_create_by!(email: "staff@#{attrs[:slug]}.test") do |user|
      user.password = "password123"
      user.name = "#{attrs[:name]} Staff"
      user.operator = operator
      user.roles = ["operator_customer_service"]
    end

    3.times do |v|
      venue = operator.venues.find_or_create_by!(name: "#{attrs[:name]} Venue #{v + 1}")
      2.times do |f|
        facility = venue.facilities.find_or_create_by!(name: "Hall #{f + 1}") { |fac| fac.capacity = 20 + (f * 10) }
        next if facility.booking_instances.exists?

        5.times do |b|
          starts = (b - 2).days.from_now.change(hour: 9 + b, min: 0)
          facility.booking_instances.create!(
            starts_at: starts,
            ends_at: starts + 2.hours,
            status: b.even? ? "completed" : "confirmed",
            verification_status: VERIFICATION_CYCLE[b % 4]
          )
        end
      end
    end
  end

  app = Doorkeeper::Application.find_or_create_by!(name: "Seed API Client") do |a|
    a.redirect_uri = "https://example.test/callback"
  end
  staff = OperatorUser.find_by!(email: "staff@acme.test")
  token = Doorkeeper::AccessToken.find_or_create_by!(resource_owner_id: staff.id, application_id: app.id) do |t|
    t.scopes = "read bookings"
  end

  puts "Seeded. Logins (password: password123): admin@enni.test, staff@acme.test, staff@borough.test"
  puts "Pre-wired API token (operator: acme, scopes: read bookings): #{token.token}"
end
