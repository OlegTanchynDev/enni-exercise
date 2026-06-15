# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingInstance do
  it { is_expected.to belong_to(:facility) }
  it { is_expected.to belong_to(:customer).class_name("User").optional }
  it { is_expected.to have_many(:cleaning_photos).dependent(:destroy) }

  describe "validations" do
    it "rejects an end time that is not after the start time" do
      at = 1.day.from_now
      booking = build(:booking_instance, starts_at: at, ends_at: at)
      expect(booking).not_to be_valid
      expect(booking.errors[:ends_at]).to be_present
    end
  end

  describe "status lifecycle (provided pattern)" do
    let(:booking) { create(:booking_instance) }

    it "starts provisional" do
      expect(booking).to be_provisional
    end

    it "moves provisional -> confirmed -> completed and audits each step" do
      expect { booking.confirm! && booking.complete! }.to change { booking.audits.count }.by(2)
      expect(booking).to be_completed
    end
  end

  describe "verification_status lifecycle" do
    it "defaults to unverified" do
      expect(build(:booking_instance).verification_status).to eq("unverified")
    end

    it "moves unverified -> verified for a passing verification" do
      booking = create(:booking_instance, :completed)
      booking.start_verification!
      booking.pass_verification!
      expect(booking).to be_verified
    end
  end
end
