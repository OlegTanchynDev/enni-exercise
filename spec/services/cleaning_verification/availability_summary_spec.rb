# frozen_string_literal: true

require "rails_helper"

# TASK 3b: this exercises the AI-generated AvailabilitySummary you are asked to
# review and fix. It will not pass until you have repaired the file. Strengthen
# these examples as you go (e.g. assert there is no N+1, and that the digest is
# scoped to the right operator).
RSpec.describe CleaningVerification::AvailabilitySummary do
  it "builds a digest of the operator's upcoming bookings" do
    skip "TASK 3b: review and fix app/services/cleaning_verification/availability_summary.rb"
    operator = create(:operator)
    facility = create(:facility, venue: create(:venue, operator: operator))
    create(:booking_instance, :completed, facility: facility, starts_at: 2.days.from_now,
                                          ends_at: 2.days.from_now + 1.hour)

    result = described_class.new(operator).call

    expect(result[:rows].size).to eq(1)
  end
end
