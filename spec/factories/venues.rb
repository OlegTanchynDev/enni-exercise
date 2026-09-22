# frozen_string_literal: true

FactoryBot.define do
  factory :venue do
    association :operator
    sequence(:name) { |n| "Venue #{n}" }
    address { "1 Test Street" }
  end
end
