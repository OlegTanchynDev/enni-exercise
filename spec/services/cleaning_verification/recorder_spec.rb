# frozen_string_literal: true

require "rails_helper"

RSpec.describe CleaningVerification::Recorder do
  let(:booking) { create(:booking_instance, :completed) }

  describe "#record" do
    it "marks a passing verdict as verified" do
      skip "TASK 1a: implement Recorder + the verification AASM, then delete this skip line"
      verdict = double("verdict", passed?: true)
      described_class.new(booking_instance: booking, verdict: verdict).record
      expect(booking.reload.verification_status).to eq("verified")
    end

    it "marks a failing verdict as flagged" do
      skip "TASK 1a: implement Recorder + the verification AASM"
      verdict = double("verdict", passed?: false)
      described_class.new(booking_instance: booking, verdict: verdict).record
      expect(booking.reload.verification_status).to eq("flagged")
    end

    it "is safe to run on a booking that is already verified (idempotency)" do
      skip "TASK 1a: decide and test your idempotency/guard behaviour"
    end
  end
end
