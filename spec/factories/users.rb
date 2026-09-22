# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.test" }
    password { "password123" }
    name { "Test User" }
  end

  factory :system_admin, parent: :user, class: "SystemAdmin" do
    name { "System Admin" }
  end

  factory :operator_user, parent: :user, class: "OperatorUser" do
    association :operator
    name { "Operator Staff" }

    transient do
      role { :operator_customer_service }
    end

    roles { [role.to_s] }
  end

  factory :customer, parent: :user, class: "Customer" do
    name { "Customer" }
  end
end
