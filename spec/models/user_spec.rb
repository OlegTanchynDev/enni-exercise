# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  describe "STI predicates" do
    it "identifies a system admin" do
      expect(build(:system_admin)).to be_system_admin
    end

    it "identifies an operator user" do
      user = build(:operator_user)
      expect(user).to be_operator
      expect(user).not_to be_system_admin
    end

    it "identifies a customer" do
      expect(build(:customer)).to be_customer
    end
  end

  describe "#has_role?" do
    it "reads the roles array" do
      user = build(:operator_user, role: :operator_admin)
      expect(user).to have_role(:operator_admin)
      expect(user).not_to have_role(:operator_customer_service)
    end
  end
end
