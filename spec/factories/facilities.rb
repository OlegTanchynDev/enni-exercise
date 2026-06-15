# frozen_string_literal: true

FactoryBot.define do
  factory :facility do
    association :venue
    sequence(:name) { |n| "Facility #{n}" }
    capacity { 30 }
  end
end
