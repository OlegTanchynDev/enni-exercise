# frozen_string_literal: true

require "rails_helper"

RSpec.describe CleaningVerification::Recorder do
  let(:booking) { create(:booking_instance, :completed) }

  describe "#record" do
    before do
      booking.start_verification!
    end

    it "marks a passing verdict as verified" do
      verdict = double("verdict", passed?: true)
      described_class.new(booking_instance: booking, verdict: verdict).record
      expect(booking.reload.verification_status).to eq("verified")
    end

    it "marks a failing verdict as flagged" do
      verdict = double("verdict", passed?: false)
      described_class.new(booking_instance: booking, verdict: verdict).record
      expect(booking.reload.verification_status).to eq("flagged")
    end

    it "is safe to run on a booking that is already verified (idempotency)" do
      booking.pass_verification!
      verdict = double("verdict", passed?: false)
      described_class.new(booking_instance: booking, verdict: verdict).record
      expect(booking.reload.verification_status).to eq("verified")
    end
  end
end
