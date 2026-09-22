# frozen_string_literal: true

require "rails_helper"

RSpec.describe Operator do
  it { is_expected.to have_many(:venues).dependent(:destroy) }
  it { is_expected.to have_many(:operator_users).dependent(:destroy) }
  it { is_expected.to have_many(:facilities).through(:venues) }
  it { is_expected.to have_many(:booking_instances).through(:facilities) }

  it "is invalid without a name" do
    expect(build(:operator, name: nil)).not_to be_valid
  end
end
