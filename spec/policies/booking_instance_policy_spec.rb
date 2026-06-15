# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingInstancePolicy do
  let_it_be(:operator) { create(:operator) }
  let_it_be(:other_operator) { create(:operator) }
  let_it_be(:booking) do
    create(:booking_instance, :completed, facility: create(:facility, venue: create(:venue, operator: operator)))
  end

  def policy_for(user)
    described_class.new(UserContext.new(current_user: user, true_user: user), booking)
  end

  describe "#verify?" do
    it "allows a system admin" do
      expect(policy_for(create(:system_admin)).verify?).to be(true)
    end

    it "allows a customer-service operator of the SAME operator" do
      user = create(:operator_user, operator: operator, role: :operator_customer_service)
      expect(policy_for(user).verify?).to be(true)
    end

    it "does not allow a customer" do
      expect(policy_for(create(:customer)).verify?).to be(false)
    end

    it "does NOT allow a customer-service operator of ANOTHER operator" do
      skip "TASK 1c: find & fix the planted IDOR in the policy, then delete this skip line"
      user = create(:operator_user, operator: other_operator, role: :operator_customer_service)
      expect(policy_for(user).verify?).to be(false)
    end
  end

  describe "Scope" do
    it "returns only the caller operator's bookings" do
      user = create(:operator_user, operator: operator, role: :operator_customer_service)
      create(:booking_instance, facility: create(:facility, venue: create(:venue, operator: other_operator)))
      ctx = UserContext.new(current_user: user, true_user: user)
      resolved = BookingInstancePolicy::Scope.new(ctx, BookingInstance.all).resolve
      expect(resolved).to contain_exactly(booking)
    end
  end
end
